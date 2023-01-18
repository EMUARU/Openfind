#!/usr/bin/python3
import os
import signal
import uuid
import sys

from flask import Flask, request, render_template, redirect, url_for, send_from_directory, session
from flask_uploads import UploadSet, configure_uploads

import sqlite as sql

from datetime import datetime


EXTENSIONS = ('tgz', 'zip', 'pdf', 'gz')

app = Flask(__name__)

app.config['SECRET_KEY'] = 'product_module_management_system'
app.config['UPLOADED_DEF_DEST'] = '/'

uploadSet = UploadSet(name='def', extensions=EXTENSIONS)
configure_uploads(app, uploadSet)

host_prefix = 'http://172.16.1.79'
filename_prefix = '/disk1/htdocs'
txt_path = '/disk1/htdocs/files.txt'


def search_list(query_filter):
    dic_list = sql.search_filter(query_filter)
    for data in dic_list:
        data["product"] = "--" if (data["product"] == '') else data["product"]
        data["version"] = "--" if (data["version"] == '') else data["version"]
        data["systemtype"] = "--" if (data["systemtype"] == 0) else data["systemtype"]
        data["servertype"] = "--" if (data["servertype"] == '') else data["servertype"]
        data["name"] = "--" if (data["name"] == '') else data["name"]
        data["os"] = "--" if (data["os"] == '') else data["os"]
        data["link"] = "--" if (data["link"] == '') else data["link"]

    return dic_list


@app.route('/', methods=['GET'])
def home():
    unique_product_list = sql.search_product()
    
    session['new_products_uuid'] = {}
    session['delete_uuid'] = []

    return render_template('home.html', title='home', unique_product_list=unique_product_list)


@app.route('/Product', methods=['POST'])
def get_product():
    product = request.form.get('product')

    return redirect(url_for('product', product=product), code=307)


@app.route('/Product/<product>', methods=['POST', 'GET'])
def product(product):
    unique_product_list = sql.search_product()
    unique_version_list = sql.search_version(product)

    return render_template('home.html', title='home', product=product,
                           unique_product_list=unique_product_list, unique_version_list=unique_version_list)


@app.route('/Version', methods=['POST'])
def get_version():
    version = request.form.get('version')
    product = request.form.get('product')

    return redirect(url_for('version', product=product, version=version), code=307)


@app.route('/Product/<product>/Version/<version>', methods=['POST', 'GET'])
def version(product, version):
    unique_product_list = sql.search_product()
    unique_version_list = sql.search_version(product)
    query_filter = {"product": product, "version": version}
    product_list = search_list(query_filter)

    if "check_update_file" in request.form:
        check_update_file = True
    else:
        check_update_file = False
        
    new_products_uuid = session.get('new_products_uuid')
    delete_uuid = session.get('delete_uuid')
    
    if(delete_uuid is not None):
        for id in delete_uuid:
            del(new_products_uuid[id])
            
    session['new_products_uuid'] = False
    session['new_products_uuid'] = new_products_uuid
    delete_uuid = []
    
    new_products = []
        
    if 'uuid' in request.form:
        uuid1 = request.form.get('uuid')
        delete_uuid.append(uuid1)
        new_products = session.get('new_products_uuid')[uuid1]
        
    session['delete_uuid'] = False
    session['delete_uuid'] = delete_uuid

    return render_template('product.html', title='products', product=product, version=version,
                           unique_product_list=unique_product_list, unique_version_list=unique_version_list,
                           product_list=product_list, check_update_file=check_update_file, new_products=new_products)


@app.route('/insert_form', methods=['POST'])
def insert_form():
    product = request.form.get('product')
    version = request.form.get('version')
    unique_product_list = sql.search_product()
    unique_version_list = sql.search_version(product)
    query_filter = {"product": product, "version": version}
    product_list = search_list(query_filter)

    return render_template('form.html', title='insert_form', product=product, version=version,
                           unique_product_list=unique_product_list, unique_version_list=unique_version_list,
                           product_list=product_list, insert_mode=True)
                           

@app.route('/new_version', methods=['POST'])
def new_version():
    product = request.form.get('product')
    version = "new_version"
    unique_product_list = sql.search_product()
    unique_version_list = sql.search_version(product)
    query_filter = {"product": product, "version": version}
    product_list = search_list(query_filter)

    return render_template('form.html', title='insert_form', product=product, version=version,
                           unique_product_list=unique_product_list, unique_version_list=unique_version_list,
                           product_list=product_list, insert_mode=True, new_version_mode=True)


@app.route('/add_item_cancel', methods=['POST'])
def add_item_cancel():
    product = request.form.get('product')
    version = request.form.get('version')
    
    if version == 'new_version':
        return redirect(url_for('product', product=product), code=307)

    return redirect(url_for('version', product=product, version=version), code=307)


@app.route('/add_item', methods=['POST'])
def add_item():
    product = request.form.get('product')
    version = request.form.get('version')

    return redirect(url_for('upload_and_insert'), code=307)


@app.route('/upload_and_insert', methods=['POST'])
def upload_and_insert():
    items, files = request.form, request.files
    product = items.get('product')
    version = items.get('version')
    unique_product_list = sql.search_product()
    unique_version_list = sql.search_version(product)
    query_filter = {"product": product, "version": version}
    product_list = search_list(query_filter)

    number_of_new_item = int(items['number_of_new_item'])
    upload_fail_index = []
    new_products = []
    
    insert = True
    upload_filename = ""
    data_number = []

    i, count = 0, 0
    while True:
        if count == number_of_new_item:
            break
    
        if item_attribute_name('v', i) in items:
            link = ""
            if items[item_attribute_name('upload_file', i)] == 'yes':
                link = items[item_attribute_name('l', i)]
                estimate_file_path = filename_prefix + link
                same_name_file_exist = os.path.isfile(estimate_file_path)
                
                try:
                    signal.signal(signal.SIGALRM, handler)
                    signal.alarm(300)
                    upload_filename = upload_file(files[item_attribute_name('fi', i)], link)
                except AssertionError:
                    upload_fail_index.append(i)
                    print("upload file timeout")
                    insert = False
                    
                    delete_file_path = filename_prefix + link
                    if not same_name_file_exist:
                        if os.path.isfile(delete_file_path):
                            os.remove(delete_file_path)
                            print('delete_timeout_file :', delete_file_path)
                    else:
                        base_file_name = os.path.basename(link)
                        
                        base_file_name_without_extension = os.path.splitext(base_file_name)[0]
                        base_file_name_extension = os.path.splitext(base_file_name)[1]
                        
                        j = 1
                        while os.path.isfile(filename_prefix + os.path.dirname(link) + '/' + base_file_name_without_extension + '_' + str(j) + base_file_name_extension):
                            j += 1
                        delete_file_path = filename_prefix + os.path.dirname(link) + '/' + base_file_name_without_extension + '_' + str(j-1) + base_file_name_extension
                        
                        if os.path.isfile(delete_file_path):
                            os.remove(delete_file_path)
                            print('delete_timeout_file :', delete_file_path)
                    
                finally:
                    signal.alarm(0)
                    signal.signal(signal.SIGALRM, signal.SIG_DFL)
                    
                if insert:
                    link = os.path.dirname(link) + '/' + upload_filename
                    print('insert file : upload ok')
                else:
                    print('insert file : upload fail')

            if insert:
                system_type = 0 if items[item_attribute_name('st', i)] == "" else items[item_attribute_name('st', i)]
                new_products.append(
                    sql.insert(product, items[item_attribute_name('v', i)], system_type,
                               items[item_attribute_name('t', i)],
                               items[item_attribute_name('n', i)], items[item_attribute_name('o', i)], link))
                print('insert data : insert ok')
            
            data_number.append(i)
            count += 1
        
        i += 1
        
    uuid1 = str(uuid.uuid1())
    
    new_products_uuid = session.get('new_products_uuid')
    
    new_products_uuid[uuid1] = new_products
    session['new_products_uuid'] = False
    session['new_products_uuid'] = new_products_uuid
    
    return render_template('upload_state.html', title='upload_state', product=product, version=version,
                           unique_product_list=unique_product_list, unique_version_list=unique_version_list,
                           product_list=product_list, insert_data=items, upload_fail_index=upload_fail_index,
                           number_of_new_item=number_of_new_item, insert_mode=True, uuid=uuid1, data_number=data_number)


def upload_file(file, path):
    global app
    path = os.path.dirname(path)
    app.config['UPLOADED_DEF_DEST'] = filename_prefix + path
    configure_uploads(app, uploadSet)
    upload_filename = uploadSet.save(file)
    return upload_filename


def item_attribute_name(attribute, index):
    return "{}({})".format(attribute, str(index))


@app.route('/delete_or_update', methods=['POST'])
def delete_or_update():
    form = request.form
    if "delete" in form:
        return delete_item(request.form["delete"], request.form["product"], request.form["version"])
    elif "update" in form:
        return redirect(url_for('update_form'), code=307)


@app.route('/update_form', methods=['POST'])
def update_form():
    update_id = request.form["update"]
    old_item = sql.search_filter({"Id": update_id})[0]
    old_item['systemtype'] = "" if old_item['systemtype'] == 0 else old_item['systemtype']

    product = request.form.get('product')
    version = request.form.get('version')
    unique_product_list = sql.search_product()
    unique_version_list = sql.search_version(product)
    query_filter = {"product": product, "version": version}
    product_list = search_list(query_filter)

    return render_template('update.html', title='update_form', product=product, version=version,
                           unique_product_list=unique_product_list, unique_version_list=unique_version_list,
                           product_list=product_list, old_item=old_item, update_mode=True)


@app.route('/update_item', methods=['POST'])
def update_item():
    update_id = request.form['update_id']
    old_item = sql.search_filter({"Id": update_id})[0]

    link = old_item['link']
    old_link = old_item['link']
    item, file = request.form, request.files
    number_of_new_item = 1
    upload_fail_index = []
    new_products = []

    update = True
    upload_filename = ""

    if item[item_attribute_name('upload_file', 0)] == 'yes':
        link = item[item_attribute_name('l', 0)]
        estimate_file_path = filename_prefix + link
        same_name_file_exist = os.path.isfile(estimate_file_path)
        try:
            signal.signal(signal.SIGALRM, handler)
            signal.alarm(300)
            upload_filename = upload_file(file[item_attribute_name('fi', 0)], link)
        except AssertionError:
            upload_fail_index.append(0)
            print("upload file timeout")
            update = False
                
            delete_file_path = filename_prefix + link
            if not same_name_file_exist:
                if os.path.isfile(delete_file_path):
                    os.remove(delete_file_path)
                    print('delete_timeout_file :', delete_file_path)
            else:
                base_file_name = os.path.basename(link)
                
                base_file_name_without_extension = os.path.splitext(base_file_name)[0]
                base_file_name_extension = os.path.splitext(base_file_name)[1]
                
                j = 1
                while os.path.isfile(filename_prefix + os.path.dirname(link) + '/' + base_file_name_without_extension + '_' + str(j) + base_file_name_extension):
                    j += 1
                delete_file_path = filename_prefix + os.path.dirname(link) + '/' + base_file_name_without_extension + '_' + str(j-1) + base_file_name_extension
                
                if os.path.isfile(delete_file_path):
                    os.remove(delete_file_path)
                    print('delete_timeout_file :', delete_file_path)
        finally:
            signal.alarm(0)
            signal.signal(signal.SIGALRM, signal.SIG_DFL)
            
            if update:
                link = os.path.dirname(link) + '/' + upload_filename
                print('update file : upload ok')
                old_file_path = filename_prefix + old_link
                if(os.path.isfile(old_file_path)):
                    os.remove(old_file_path)
                    print('delete_file :', old_file_path)
                print('delete old file ok')
            else:
                print('update file : upload fail')

    if update:
        system_type = 0 if (item[item_attribute_name('st', 0)] == "") else item[item_attribute_name('st', 0)]
        modify_item = {"version": item[item_attribute_name('v', 0)],
                       "systemtype": system_type,
                       "servertype": item[item_attribute_name('t', 0)],
                       "name": item[item_attribute_name('n', 0)],
                       "os": item[item_attribute_name('o', 0)],
                       "link": link}
        sql.update(update_id, modify_item)
        new_products.append(int(update_id))
        print('update data : update ok')
        
       
    uuid1 = str(uuid.uuid1())
    
    new_products_uuid = session.get('new_products_uuid')
    
    new_products_uuid[uuid1] = new_products
    session['new_products_uuid'] = False
    session['new_products_uuid'] = new_products_uuid

    product = request.form.get('product')
    version = request.form.get('version')
    unique_product_list = sql.search_product()
    unique_version_list = sql.search_version(product)
    query_filter = {"product": product, "version": version}
    product_list = search_list(query_filter)

    return render_template('upload_state.html', title='upload_state', product=product, version=version,
                           unique_product_list=unique_product_list, unique_version_list=unique_version_list,
                           product_list=product_list, insert_data=item, upload_fail_index=upload_fail_index,
                           number_of_new_item=number_of_new_item, update_mode=True, uuid=uuid1, data_number=[0])


def delete_item(delete_id, product, version):
    dic_list = sql.search_filter({'Id': delete_id})
    delete_product = dic_list[0]
    delete_file_path = filename_prefix + delete_product['link']
    
    if(os.path.isfile(delete_file_path)):
        os.remove(delete_file_path)
        print('delete_file :', delete_file_path)
    print('delete data ok')
    
    sql.delete(delete_id)
    sql.exportcsv(txt_path)

    return redirect(url_for('version', product=product, version=version), code=307)


@app.route('/update_file', methods=['POST'])
def update_file():
    sql.exportcsv(txt_path, insertHost)
    product = request.form.get('product')
    version = request.form.get('version')

    return redirect(url_for('version', product=product, version=version), code=307)


def insertHost(data):
    data['link'] = host_prefix + data['link']
    return data


@app.route('/download_file', methods=['POST'])
def download_file():
    path = request.form.get('download_file_path')
    product = request.form.get('product')
    version = request.form.get('version')
    dirname = os.path.dirname(path)
    print(dirname, os.path.basename(path))
    return send_from_directory(filename_prefix + dirname, os.path.basename(path))


def handler(signum, frame):
    raise AssertionError


if __name__ == '__main__':
    print("Now is {}".format(datetime.now()), file = sys.stderr )
    sql.dbInit()
    app.run(host='172.16.1.79', port=5000, use_reloader=False, threaded=False, processes=100)
