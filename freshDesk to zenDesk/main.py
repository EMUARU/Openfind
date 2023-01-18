import os
import json
import shutil
import time
import freshdesk.v2.api as fd
import requests
from requests.structures import CaseInsensitiveDict
import urllib.request
from bs4 import BeautifulSoup
import itertools
import re

from expection import *

MAX_ATTACHMENTS_NUMBER = 20


def set_config():
    """Set Freshdesk and Zendesk credentials"""
    global fd_domain, fd_apikey, zd_domain, zd_email, zd_password, locale, user_segment_ids, permission_group_id, user_segment_refer
    with open("conf.json") as jsonFile:
        conf = json.load(jsonFile)
        fd_domain = conf['fd_domain']
        fd_apikey = conf['fd_apikey']
        zd_domain = conf['zd_domain']
        zd_email = conf['zd_email']
        zd_password = conf['zd_password']
        locale = conf['locale'].lower()
        _user_segment_id = conf['user_segment_id']
        user_segment_ids = {1: _user_segment_id['everyone'],
                            2: _user_segment_id['logged_in_user'],
                            3: _user_segment_id['agents_administrators'],
                            4: _user_segment_id['agents_administrators'],
                            5: _user_segment_id['agents_administrators']}
        permission_group_id = conf['permission_group_id']
        jsonFile.close()


def headers():
    """Return headers for Zendesk"""
    _headers = CaseInsensitiveDict()
    _headers["Content-Type"] = "application/json"
    return _headers


def zd_auth():
    """Return authentication for Zendesk"""
    _auth = (zd_email, zd_password)
    return _auth


def fd_auth():
    """Return authentication for Freshdesk"""
    _auth = (fd_apikey, 'X')
    return _auth


def all_locale_expressions():
    """Return all locale expressions from locale of Freshdesk"""
    return list(set(map(''.join, itertools.product(*zip(locale.upper(), locale.lower())))))


def check_request_exception(status_code, exception_type, err_mess):
    """Check the response status of the request"""
    status = int(status_code) // 100
    if status == 5:
        raise ServerError('{} -> {}'.format(status_code, err_mess))
    elif int(status_code) == 403:
        raise AccessDenied('')
    elif status != 2:
        raise exception_type('{} -> {}'.format(status_code, err_mess))


def solution_migration():
    """Migrate solution from Freshdesk to Zendesk"""
    fd_api = fd.API(fd_domain, fd_apikey)
    global fd_solution_api
    fd_solution_api = fd.SolutionAPI(fd_api)
    article_migration()
    update_article_link()
    remaining_fd_associated_articles()
    remaining_articles()


def article_migration():
    """Migrate all old article content and attachment files"""
    r_articles = []
    global fd_article_info, fd_folder_info, fd_category_info
    fd_article_info, fd_folder_info, fd_category_info = {}, {}, {}
    fd_categories = list(reversed(list_fd_categories()))
    for fd_category in fd_categories:
        fd_category_info[int(fd_category['id'])] = {
            'category_name': fd_category['name']
        }
        new_category_id = create_new_category(fd_category)
        fd_folders = list(reversed(list_fd_folders(fd_category['id'])))
        for fd_folder in fd_folders:
            fd_folder_info[int(fd_folder['id'])] = {
                'category_name': fd_category['name'],
                'folder_name': fd_folder['name']
            }
            new_section_id = create_new_section(fd_folder, new_category_id)
            fd_articles = list(reversed(list_fd_articles(fd_folder['id'])))
            for fd_article in fd_articles:
                fd_article = fd_solution_api.articles.get_article(int(fd_article['id']))
                fd_article_info[int(fd_article.id)] = {
                    'category_name': fd_category['name'],
                    'folder_name': fd_folder['name'],
                    'article_title': fd_article.title
                }
                retry = 0
                while True:
                    try:
                        migrate_one_article(fd_article, new_section_id, fd_folder['visibility'])
                    except AccessDenied:
                        ra = [fd_article, new_section_id, fd_folder['visibility']]
                        r_articles.append(ra)
                    except Exception as e:
                        if retry > 3 and article_migration.exception == str(e):
                            raise e
                        article_migration.exception = str(e)
                        retry += 1
                        time.sleep(1)
                        continue
                    break

    global migrate_manually_articles
    migrate_manually_articles = []
    if len(r_articles) > 0:
        for ra in r_articles:
            migrate_manually_articles.append({
                    'fd_article_id': ra[0].id,
                    'new_zd_section_id': ra[1],
                    'fd_folder_visibility': ra[2]
                })
        with open('migrate_manually_articles.json', 'w', encoding='utf-8') as f:
            json.dump(migrate_manually_articles, f, ensure_ascii=False, indent=4)
        with open('fd_article_info.json', 'w', encoding='utf-8') as f:
            json.dump(fd_article_info, f, ensure_ascii=False, indent=4)
        with open('fd_folder_info.json', 'w', encoding='utf-8') as f:
            json.dump(fd_folder_info, f, ensure_ascii=False, indent=4)
        with open('fd_category_info.json', 'w', encoding='utf-8') as f:
            json.dump(fd_category_info, f, ensure_ascii=False, indent=4)


def migrate_one_article(fd_article, new_section_id, user_segment):
    """Migrate one old article content and attachment files"""
    old_inline_attachment_urls, inline_attachment_names = get_inline_attachment_info(fd_article.description)
    inline_attachment_count = get_attachment(old_inline_attachment_urls, inline_attachment_names)
    new_inline_attachment_ids, new_inline_attachment_urls = put_attachment(inline_attachment_count,
                                                                           inline_attachment_names)
    old_viewable_attachment_urls, viewable_attachment_names = get_viewable_attachment_info(fd_article.attachments)
    viewable_attachment_count = get_attachment(old_viewable_attachment_urls, viewable_attachment_names)
    new_viewable_attachment_ids, _ = put_attachment(viewable_attachment_count, viewable_attachment_names,
                                                    inline='false')
    fd_article.description = replace_url_in_description(fd_article.description,
                                                        old_inline_attachment_urls, new_inline_attachment_urls)
    new_article_id = create_new_article(fd_article, new_section_id, user_segment)
    attachment_ids = new_inline_attachment_ids + new_viewable_attachment_ids
    if len(attachment_ids) > 0:
        associate_attachment(new_article_id, attachment_ids)
        del_attachment()


def get_inline_attachment_info(description):
    """Get information about inline attachment from Freshdesk"""
    fd_attachment_route = ['https://s3.amazonaws.com/cdn.freshdesk.com',
                           'https://attachment.freshdesk.com/inline/attachment']
    tags = [{'tag': 'img', 'attr': 'src'}, {'tag': 'a', 'attr': 'href'}]
    old_inline_attachment_urls = find_urls_from_description(description, fd_attachment_route, tags)
    inline_attachment_names = ["inline_attachment_{}".format(str(file_number)) for file_number in
                               range(1, len(old_inline_attachment_urls) + 1)]
    return old_inline_attachment_urls, inline_attachment_names


def get_viewable_attachment_info(attachments):
    """Get information about not inline attachment from Freshdesk"""
    return [attachment['attachment_url'] for attachment in attachments], \
           [attachment['name'] for attachment in attachments]


def find_urls_from_description(description, specific_routes, tags):
    """Find urls from article description"""
    urls = []
    soup = BeautifulSoup(description, 'html.parser')
    for tag in tags:
        for link in soup.find_all(tag['tag']):
            url = link.get(tag['attr'])
            for specific_route in specific_routes:
                if url is not None and specific_route in str(url):
                    urls.append(url)
                    break
    return urls


def get_attachment(old_attachment_url, attachment_name):
    """Download attachments from urls"""
    file_number = 0
    for url in old_attachment_url:
        file_number += 1
        if not os.path.isdir('attachment'):
            os.mkdir('attachment')
        try:
            urllib.request.urlretrieve(url, "./attachment/{}".format(str(attachment_name[file_number - 1])))
        except Exception:
            raise GetAttachmentException('Can not get attachment file from url : "{}"'.format(url))
    return file_number


def put_attachment(attachment_count, attachment_name, inline='true'):
    """Upload attachments of Freshdesk article to Zendesk"""
    new_attachment_ids = []
    new_attachment_urls = []
    attachments_url = "https://{}/api/v2/help_center/articles/attachments.json".format(zd_domain)
    for file_number in range(1, attachment_count + 1):
        file = open("./attachment/{}".format(str(attachment_name[file_number - 1])), 'rb')
        files = {
            'inline': (None, inline),
            'file': file,
        }
        response = requests.post(attachments_url, files=files, auth=zd_auth())
        check_request_exception(response.status_code, PutAttachmentException, response.text)
        new_attachment_ids.append(response.json()['article_attachment']['id'])
        new_attachment_urls.append(response.json()['article_attachment']['content_url'])
    return new_attachment_ids, new_attachment_urls


def replace_url_in_description(description, old_urls, new_urls):
    """Replace url in article description"""
    for index in range(len(old_urls)):
        description = description.replace(old_urls[index], new_urls[index])
    return description


def del_attachment():
    """Delete attachments folder """
    if os.path.isdir('attachment'):
        shutil.rmtree('attachment')


def create_new_category(fd_category):
    """Create new Zendesk category"""
    json_data = {
        'category': {
            'locale': locale,
            'name': fd_category['name'],
            'description': fd_category['description'],
        },
    }
    url = 'https://{}/api/v2/help_center/categories.json'.format(zd_domain)
    response = requests.post(url, headers=headers(), json=json_data, auth=zd_auth())
    check_request_exception(response.status_code, CreateZendeskCategoryException, response.text)
    return response.json()['category']['id']


def create_new_section(fd_folder, zd_category_id):
    """Create new Zendesk section"""
    json_data = {
        'section': {
            'locale': locale,
            'name': fd_folder['name'],
            'description': fd_folder['description'],
        },
    }
    url = 'https://{}/api/v2/help_center/categories/{}/sections.json'.format(zd_domain, zd_category_id)
    response = requests.post(url, headers=headers(), json=json_data, auth=zd_auth())
    check_request_exception(response.status_code, CreateZendeskSectionException, response.text)
    return response.json()['section']['id']


def create_new_article(fd_article, zd_section_id, user_segment):
    """Create new Zendesk article"""
    title = html_to_json_format(fd_article.title)
    description = html_to_json_format(fd_article.description)
    user_segment_id = user_segment_ids[user_segment]
    draft = 'true' if fd_article.status == 'draft' else 'false'
    # 只要有發布過就不會被轉移成草稿，所有文章都會取到最新的內容，就算他是草稿

    json_data = '{ \
        "article": { \
            "title": "' + title + '", \
            "body": "' + description + '", \
            "locale": "' + locale + '", \
            "user_segment_id": ' + user_segment_id + ', \
            "permission_group_id": ' + permission_group_id + ', \
            "draft": ' + draft + ', \
            "comments_disabled": true \
        }, \
        "notify_subscribers": false \
    }'

    url = "https://{}/api/v2/help_center/zh-tw/sections/{}/articles".format(zd_domain, zd_section_id)
    response = requests.post(url, headers=headers(), data=json_data, auth=zd_auth())
    check_request_exception(response.status_code, CreateZendeskArticleException, response.text)
    print('fd_article : ', fd_article.title, end=' : ')
    if response.status_code == 201:
        print('status -> migrate succeeded')
    else:
        print('status -> migrate failed')
    return response.json()['article']['id']


def html_to_json_format(content: str):
    """Convert html content to json format"""
    return content.replace('\\', "\\\\").replace('&quot;', '"').replace('"', '\\"').encode("utf-8").decode("latin-1")


def divide_chunks(_list, number):
    """Split attachments into maximum limit"""
    for index in range(0, len(_list), number):
        yield _list[index:index + number]


def associate_attachment(new_article_id, new_attachment_ids):
    """Associate attachment to Zendesk article"""
    split_attachment_ids = list(divide_chunks(new_attachment_ids, MAX_ATTACHMENTS_NUMBER))
    for split_attachment_id in split_attachment_ids:
        json_data = {
            'attachment_ids':
                split_attachment_id
        }
        url = "https://{}/api/v2/help_center/articles/{}/bulk_attachments.json".format(zd_domain, new_article_id)
        response = requests.post(url, headers=headers(), json=json_data, auth=zd_auth())
        check_request_exception(response.status_code, AssociateAttachmentException, response.text)


def update_article_link():
    """Update links that refer to Freshdesk resources in Zendesk article"""
    # global fd_article_info, fd_folder_info, fd_category_info
    #
    # with open('fd_article_info.json', 'r', encoding='utf-8') as json_file:
    #     fd_article_info = json.load(json_file)
    # with open('fd_folder_info.json', 'r', encoding='utf-8') as json_file:
    #     fd_folder_info = json.load(json_file)
    # with open('fd_category_info.json', 'r', encoding='utf-8') as json_file:
    #     fd_category_info = json.load(json_file)
    #
    # fd_article_info = {int(k): v for k, v in fd_article_info.items()}
    # fd_folder_info = {int(k): v for k, v in fd_folder_info.items()}
    # fd_category_info = {int(k): v for k, v in fd_category_info.items()}
    global lost_ref_link_articles
    lost_ref_link_articles = []
    zd_categories = list_zd_categories()
    for zd_category in zd_categories:
        zd_sections = list_zd_sections(zd_category['id'])
        for zd_section in zd_sections:
            zd_articles = list_zd_articles(zd_section['id'])
            for zd_article in zd_articles:
                retry = 0
                while True:
                    try:
                        description = zd_article['body']
                        locale_expressions = all_locale_expressions()
                        try:
                            article_link_changed, description = update_link_of_article(description, zd_categories,
                                                                                       zd_sections, zd_articles,
                                                                                       locale_expressions)
                        except FindZDNewArticleException:
                            article_path = '{}/{}/{}'.format(zd_category['name'], zd_section['name'], zd_article['title'])
                            article_url = zd_article['html_url']
                            lost_ref_link_articles.append({
                                'article_path': article_path,
                                'article_url': article_url
                            })
                            break

                        folder_link_changed, description = update_link_of_section(description, zd_categories,
                                                                                  zd_sections, locale_expressions)
                        category_link_changed, description = update_link_of_category(description, zd_categories,
                                                                                     locale_expressions)
                        home_link_changed, description = update_link_of_home(description, locale_expressions)
                        if article_link_changed or folder_link_changed or category_link_changed or home_link_changed:
                            print('zd_article : ', zd_article['title'], end=' : ')
                            if int(update_zd_article_description(description, zd_article['id'])) // 100 == 2:
                                print('status -> update succeeded')
                            else:
                                print('status -> update failed')
                    except Exception as e:
                        if retry > 3 and update_article_link.exception == str(e):
                            raise e
                        update_article_link.exception = str(e)
                        retry += 1
                        time.sleep(1)
                        continue
                    break

    if len(lost_ref_link_articles) > 0:
        with open('lost_ref_link_articles.json', 'w', encoding='utf-8') as f:
            json.dump(lost_ref_link_articles, f, ensure_ascii=False, indent=4)


def update_link_of_article(description, zd_categories, zd_sections, zd_articles, locale_expressions):
    """Replace links that refer to Freshdesk articles in Zendesk article"""
    article_link_changed = False
    tags = [{'tag': 'a', 'attr': 'href'}]
    fd_article_route = get_fd_article_route(locale_expressions)
    fd_article_urls = find_urls_from_description(description, fd_article_route, tags)
    zd_new_article_urls = []
    if len(fd_article_urls) > 0:
        for fd_article_url in fd_article_urls:
            fd_article_url = fd_article_url.removesuffix('edit').removesuffix('/')
            fd_article_id = int(fd_article_url.split("/")[-1].split("-")[0])
            fd_article = fd_article_info[fd_article_id]
            fd_category_name = fd_article['category_name']
            fd_folder_name = fd_article['folder_name']
            fd_article_title = fd_article['article_title']
            zd_new_article_id = find_reference_article(zd_categories, zd_sections, zd_articles,
                                                       fd_category_name, fd_folder_name, fd_article_title)
            zd_new_article = get_zd_article(zd_new_article_id)
            zd_new_article_urls.append(zd_new_article['html_url'])
        description = replace_url_in_description(description, fd_article_urls, zd_new_article_urls)
        article_link_changed = True
    return article_link_changed, description


def update_link_of_section(description, zd_categories, zd_sections, locale_expressions):
    """Replace links that refer to Freshdesk sections in Zendesk article"""
    section_link_changed = False
    tags = [{'tag': 'a', 'attr': 'href'}]
    fd_folder_route = get_fd_folder_route(locale_expressions, description)
    fd_folder_urls = find_urls_from_description(description, fd_folder_route, tags)
    zd_new_section_urls = []
    if len(fd_folder_urls) > 0:
        for fd_folder_url in fd_folder_urls:
            fd_folder_url = fd_folder_url.removesuffix('edit').removesuffix('/')
            fd_folder_id = int(fd_folder_url.split("/")[-1].split("-")[0])
            fd_folder = fd_folder_info[fd_folder_id]
            fd_category_name = fd_folder['category_name']
            fd_folder_name = fd_folder['folder_name']
            zd_new_section_id = find_reference_section(zd_categories, zd_sections,
                                                       fd_category_name, fd_folder_name)
            zd_new_section = get_zd_section(zd_new_section_id)
            zd_new_section_urls.append(zd_new_section['html_url'])
        description = replace_url_in_description(description, fd_folder_urls, zd_new_section_urls)
        section_link_changed = True
    return section_link_changed, description


def update_link_of_category(description, zd_categories, locale_expressions):
    """Replace links that refer to Freshdesk categories in Zendesk article"""
    category_link_changed = False
    tags = [{'tag': 'a', 'attr': 'href'}]
    fd_category_route = get_fd_category_route(locale_expressions)
    fd_category_urls = find_urls_from_description(description, fd_category_route, tags)
    zd_new_category_urls = []
    if len(fd_category_urls) > 0:
        for fd_category_url in fd_category_urls:
            fd_category_url = fd_category_url.removesuffix('edit').removesuffix('/')
            fd_category_id = int(fd_category_url.split("/")[-1].split("-")[0])
            fd_category = fd_category_info[fd_category_id]
            fd_category_name = fd_category['category_name']
            zd_new_category_id = find_reference_category(zd_categories, fd_category_name)
            zd_new_category = get_zd_category(zd_new_category_id)
            zd_new_category_urls.append(zd_new_category['html_url'])
        description = replace_url_in_description(description, fd_category_urls, zd_new_category_urls)
        category_link_changed = True
    return category_link_changed, description


def update_link_of_home(description, locale_expressions):
    """Replace links that refer to Freshdesk home page in Zendesk article"""
    home_link_changed = False
    fd_home_urls = ['https://{}/support/home'.format(fd_domain),
                    'https://{}/a/solutions'.format(fd_domain)]
    fd_home_urls += ['https://{}/{}/support/home'.format(fd_domain, locale_expression) for locale_expression in
                     locale_expressions]
    zd_home = 'https://{}/hc/{}'.format(zd_domain, locale)
    for fd_home_url in fd_home_urls:
        if fd_home_url in description:
            print('replace new home link : {}'.format(zd_home))
            description = description.replace(fd_home_url, zd_home)
            home_link_changed = True
    return home_link_changed, description


def get_fd_article_route(locale_expressions):
    """Get all Freshdesk article route format"""
    fd_article_route = ['https://{}/solution/articles/'.format(fd_domain),
                        'https://{}/a/solutions/articles/'.format(fd_domain),
                        'https://{}/support/solutions/articles/'.format(fd_domain)]
    fd_article_route += ('https://{}/{}/support/solutions/articles/'.format(fd_domain, locale_expression) for
                         locale_expression in locale_expressions)
    return fd_article_route


def get_fd_folder_route(locale_expressions, description):
    """Get all Freshdesk folder route format"""
    fd_folder_route = ['https://{}/a/solutions/folders/'.format(fd_domain),
                       'https://{}/support/solutions/folders/'.format(fd_domain)]
    fd_folder_route += ('https://{}/{}/support/solutions/articles/'.format(fd_domain, locale_expression) for
                        locale_expression in locale_expressions)
    tags = [{'tag': 'a', 'attr': 'href'}]
    urls = find_urls_from_description(description, [''], tags)
    special_routing_format = 'https://openfind.freshdesk.com/a/solutions/categories/.*/folders/'
    for url in urls:
        r = re.compile(special_routing_format)
        match = r.match(url)
        if match is not None:
            fd_folder_route.append(str(match.group()))
    return fd_folder_route


def get_fd_category_route(locale_expressions):
    """Get all Freshdesk category route format"""
    fd_article_route = ['https://{}/a/solutions/categories/'.format(fd_domain),
                        'https://{}/support/solutions/categories/'.format(fd_domain)]
    fd_article_route += ('https://{}/{}/support/support/solutions/categories/'.format(fd_domain, locale_expression) for
                         locale_expression in locale_expressions)
    return fd_article_route


def list_fd_categories():
    """List all Freshdesk categories"""
    page = 1
    fd_categories = []
    while True:
        url = 'https://{}/api/v2/solutions/categories?page={}'.format(fd_domain, page)
        response = requests.get(url, auth=fd_auth())
        if int(response.status_code) // 100 == 5:
            list_resource_per_page(pre_url=url.split('?')[0], err_page=page, resource=fd_categories, list_from='fd')
        else:
            check_request_exception(response.status_code, ListFreshdeskCategoriesException, response.text)
            fd_categories_per_page = response.json()
            if len(fd_categories_per_page) == 0:
                break
            fd_categories += fd_categories_per_page
        page += 1
    return fd_categories


def list_fd_folders(fd_category_id):
    """List all Freshdesk folders by category id"""
    page = 1
    fd_folders = []
    while True:
        url = 'https://{}/api/v2/solutions/categories/{}/folders?page={}'.format(fd_domain, fd_category_id, page)
        response = requests.get(url, auth=fd_auth())
        if int(response.status_code) // 100 == 5:
            list_resource_per_page(pre_url=url.split('?')[0], err_page=page, resource=fd_folders, list_from='fd')
        else:
            check_request_exception(response.status_code, ListFreshdeskFoldersException, response.text)
            fd_folders_per_page = response.json()
            if len(fd_folders_per_page) == 0:
                break
            fd_folders += fd_folders_per_page
        page += 1
    return fd_folders


def list_fd_articles(fd_folder_id):
    """List all Freshdesk articles by folder id"""
    page = 1
    fd_articles = []
    while True:
        url = 'https://{}/api/v2/solutions/folders/{}/articles?page={}'.format(fd_domain, fd_folder_id, page)
        response = requests.get(url, auth=fd_auth())
        if int(response.status_code) // 100 == 5:
            list_resource_per_page(pre_url=url.split('?')[0], err_page=page, resource=fd_articles, list_from='fd')
        else:
            check_request_exception(response.status_code, ListFreshdeskArticlesException, response.text)
            fd_articles_per_page = response.json()
            if len(fd_articles_per_page) == 0:
                break
            fd_articles += fd_articles_per_page
        page += 1
    return fd_articles


def list_resource_per_page(pre_url, err_page, resource=None, list_from='fd', zd_filter=None):
    """List resource of Freshdesk or Zendesk per page """
    if resource is None:
        resource = []
    err_page = (err_page - 1) * 30 + 1
    for page in range(err_page, err_page + 30):
        url = pre_url + '?page={}&per_page=1'.format(page)
        auth = fd_auth() if list_from == 'fd' else zd_auth()
        response = requests.get(url, auth=auth)
        if int(response.status_code) // 100 == 5:
            pass
        else:
            exception_type = ListFreshdeskArticlesException if list_from == 'fd' else ListZendeskArticlesException
            check_request_exception(response.status_code, exception_type, response.text)
            resource_per_page = response.json() if list_from == 'fd' else response.json()[zd_filter]
            if len(resource_per_page) == 0:
                break
            resource += resource_per_page
    return resource


def list_zd_categories():
    """List all Zendesk categories"""
    page = 1
    zd_categories = []
    while True:
        url = 'https://{}/api/v2/help_center/{}/categories.json?page={}'.format(zd_domain, locale, page)
        response = requests.get(url, auth=zd_auth())
        if int(response.status_code) // 100 == 5:
            list_resource_per_page(pre_url=url.split('?')[0], err_page=page, resource=zd_categories, list_from='zd',
                                   zd_filter='categories')
        else:
            check_request_exception(response.status_code, ListZendeskCategoriesException, response.text)
            zd_categories_per_page = response.json()['categories']
            if len(zd_categories_per_page) == 0:
                break
            zd_categories += zd_categories_per_page
        page += 1
    return zd_categories


def list_zd_sections(zd_category_id):
    """List all Zendesk sections by category id"""
    page = 1
    zd_sections = []
    while True:
        url = 'https://{}/api/v2/help_center/{}/categories/{}/sections.json?page={}'.format(zd_domain, locale,
                                                                                            zd_category_id, page)
        response = requests.get(url, auth=zd_auth())
        if int(response.status_code) // 100 == 5:
            list_resource_per_page(pre_url=url.split('?')[0], err_page=page, resource=zd_sections, list_from='zd',
                                   zd_filter='sections')
        else:
            check_request_exception(response.status_code, ListZendeskSectionsException, response.text)
            zd_sections_per_page = response.json()['sections']
            if len(zd_sections_per_page) == 0:
                break
            zd_sections += zd_sections_per_page
        page += 1
    return zd_sections


def list_zd_articles(zd_section_id):
    """List all Zendesk articles by section id"""
    page = 1
    zd_articles = []
    while True:
        url = 'https://{}/api/v2/help_center/{}/sections/{}/articles.json?page={}'.format(zd_domain, locale,
                                                                                          zd_section_id, page)
        response = requests.get(url, auth=zd_auth())
        if int(response.status_code) // 100 == 5:
            list_resource_per_page(pre_url=url.split('?')[0], err_page=page, resource=zd_articles, list_from='zd',
                                   zd_filter='articles')
        else:
            check_request_exception(response.status_code, ListZendeskArticlesException, response.text)
            zd_articles_per_page = response.json()['articles']
            if len(zd_articles_per_page) == 0:
                break
            zd_articles += zd_articles_per_page
        page += 1
    return zd_articles


def get_zd_category(category_id):
    """Return one Zendesk category by id"""
    url = 'https://{}/api/v2/help_center/{}/categories/{}.json'.format(zd_domain, locale, category_id)
    return get_from_url(url, zd_auth())['category']


def get_zd_section(section_id):
    """Return one Zendesk section by id"""
    url = 'https://{}/api/v2/help_center/{}/sections/{}.json'.format(zd_domain, locale, section_id)
    return get_from_url(url, zd_auth())['section']


def get_zd_article(article_id):
    """Return one Zendesk article by id"""
    url = 'https://{}/api/v2/help_center/{}/articles/{}.json'.format(zd_domain, locale, article_id)
    return get_from_url(url, zd_auth())['article']


def get_from_url(url, _auth=None):
    """Get response from url"""
    response = requests.get(url, auth=_auth)
    check_request_exception(response.status_code, GetFromURLException, response.text)
    return response.json()


def find_reference_article(zd_categories, zd_sections, zd_articles, fd_category_name, fd_folder_name, fd_article_title):
    """Find the corresponding Freshdesk article in Zendesk"""
    find, zd_new_article_id = find_reference_article_in_section(zd_articles, fd_category_name, fd_folder_name,
                                                                fd_article_title)
    if not find:
        find, zd_new_article_id = find_reference_article_in_category(zd_sections, fd_category_name, fd_folder_name,
                                                                     fd_article_title)
        if not find:
            find, zd_new_article_id = find_reference_article_in_all_articles(zd_categories, fd_category_name,
                                                                             fd_folder_name, fd_article_title)
            if not find:
                raise FindZDNewArticleException(
                    "Can not find article \"{}/{}/{}\" in Zendesk".format(fd_category_name, fd_folder_name,
                                                                          fd_article_title))
    return zd_new_article_id


def find_reference_article_in_section(zd_articles, fd_category_name, fd_folder_name, fd_article_title):
    """Find the corresponding Freshdesk article in a Zendesk section"""
    find, reference_article_id = False, -1
    for zd_article in zd_articles:
        if zd_article['title'] == fd_article_title:
            zd_section = get_zd_section(zd_article['section_id'])
            if zd_section['name'] == fd_folder_name:
                zd_category = get_zd_category(zd_section['category_id'])
                if zd_category['name'] == fd_category_name:
                    print('replace new article link :', end=' ')
                    print(zd_category['name'], zd_section['name'], zd_article['title'], sep='/')
                    find, reference_article_id = True, zd_article['id']
                    return find, reference_article_id
    return find, reference_article_id


def find_reference_article_in_category(zd_sections, fd_category_name, fd_folder_name, fd_article_title):
    """Find the corresponding Freshdesk article in a Zendesk category"""
    find, reference_article_id = False, -1
    for zd_section in zd_sections:
        zd_articles = list_zd_articles(zd_section['id'])
        find, reference_article_id = find_reference_article_in_section(zd_articles, fd_category_name,
                                                                       fd_folder_name, fd_article_title)
        if find:
            return find, reference_article_id
    return find, reference_article_id


def find_reference_article_in_all_articles(zd_categories, fd_category_name, fd_folder_name, fd_article_title):
    """Find the corresponding Freshdesk article in all Zendesk articles"""
    find, reference_article_id = False, -1
    for zd_category in zd_categories:
        zd_sections = list_zd_sections(zd_category['id'])
        find, reference_article_id = find_reference_article_in_category(zd_sections, fd_category_name,
                                                                        fd_folder_name, fd_article_title)
        if find:
            return find, reference_article_id
    return find, reference_article_id


def find_reference_section(zd_categories, zd_sections, fd_category_name, fd_folder_name):
    """Find the corresponding Freshdesk section in Zendesk"""
    find, zd_new_section_id = find_reference_section_in_category(zd_sections, fd_category_name, fd_folder_name)
    if not find:
        find, zd_new_section_id = find_reference_section_in_all_sections(zd_categories, fd_category_name,
                                                                         fd_folder_name)
        if not find:
            raise FindZDNewSectionException(
                "Can not find section \"{}/{}\" in Zendesk".format(fd_category_name, fd_folder_name))
    return zd_new_section_id


def find_reference_section_in_category(zd_sections, fd_category_name, fd_folder_name):
    """Find the corresponding Freshdesk section in a Zendesk category"""
    find, reference_section_id = False, -1
    for zd_section in zd_sections:
        if zd_section['name'] == fd_folder_name:
            zd_category = get_zd_category(zd_section['category_id'])
            if zd_category['name'] == fd_category_name:
                print('replace new section link :', end=' ')
                print(zd_category['name'], zd_section['name'], sep='/')
                find, reference_section_id = True, zd_section['id']
                return find, reference_section_id
    return find, reference_section_id


def find_reference_section_in_all_sections(zd_categories, fd_category_name, fd_folder_name):
    """Find the corresponding Freshdesk section in all Zendesk sections"""
    find, reference_section_id = False, -1
    for zd_category in zd_categories:
        zd_sections = list_zd_sections(zd_category['id'])
        find, reference_section_id = find_reference_section_in_category(zd_sections, fd_category_name, fd_folder_name)
        if find:
            return find, reference_section_id
    return find, reference_section_id


def find_reference_category(zd_categories, fd_category_name):
    """Find the corresponding Freshdesk category in Zendesk"""
    find, zd_new_category_id = find_reference_category_in_all_zd_categories(zd_categories, fd_category_name)
    if not find:
        raise FindZDNewCategoryException("Can not find category \"{}\" in Zendesk".format(fd_category_name))
    return zd_new_category_id


def find_reference_category_in_all_zd_categories(zd_categories, fd_category_name):
    """Find the corresponding Freshdesk category in all Zendesk categories"""
    find, reference_category_id = False, -1
    for zd_category in zd_categories:
        if zd_category['name'] == fd_category_name:
            print('replace new category link :', end=' ')
            print(zd_category['name'])
            find, reference_section_id = True, zd_category['id']
            return find, reference_category_id
    return find, reference_category_id


def update_zd_article_description(description, zd_article_id):
    """Update Zendesk article with new description"""
    json_data = {
        'translation': {
            'body': description,
        },
    }
    url = 'https://{}/api/v2/help_center/articles/{}/translations/{}.json'.format(zd_domain, zd_article_id, locale)
    response = requests.put(url, headers=headers(), json=json_data, auth=zd_auth())
    check_request_exception(response.status_code, UpdateZendeskArticleException, response.text)
    return response.status_code


def remaining_fd_associated_articles():
    """Check the remaining articles associated with Freshdesk"""
    global fd_associated_articles
    fd_associated_articles = []
    fd_associated_words = ['freshdesk', 'Freshdesk']
    zd_categories = list_zd_categories()
    for zd_category in zd_categories:
        zd_sections = list_zd_sections(zd_category['id'])
        for zd_section in zd_sections:
            zd_articles = list_zd_articles(zd_section['id'])
            for zd_article in zd_articles:
                description = zd_article['body']
                for fd_associated_word in fd_associated_words:
                    if fd_associated_word in description:
                        article_path = '{}/{}/{}'.format(zd_category['name'], zd_section['name'], zd_article['title'])
                        article_url = zd_article['html_url']
                        fd_associated_articles.append({
                            'article_path': article_path,
                            'article_url': article_url
                        })
                        break
    if len(fd_associated_articles) > 0:
        with open('fd_associated_articles.json', 'w', encoding='utf-8') as f:
            json.dump(fd_associated_articles, f, ensure_ascii=False, indent=4)


def remaining_articles():
    if len(fd_associated_articles) == 0 and len(migrate_manually_articles) == 0 and len(lost_ref_link_articles) == 0:
        print('\nsolution migration completed')
    else:
        print('\nsolution migration partially completed')
        if len(fd_associated_articles) > 0:
            print('\nPlease check fd_associated_articles.json for the remaining files that may be processed manually', sep='\n')
        if len(migrate_manually_articles) > 0:
            print('\nPlease check migrate_manually_articles.json for the freshdesk articles that may be migrated manually', sep='\n')
        if len(lost_ref_link_articles) > 0:
            print('\nPlease check lost_ref_link_articles.json for the remaining files that may be updated link manually', sep='\n')


if __name__ == '__main__':
    os.system("pip install -r requirements.txt")
    set_config()
    solution_migration()
