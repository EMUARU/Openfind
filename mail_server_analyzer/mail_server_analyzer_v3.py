import csv
import dns.resolver
import socket
import ssl
import re
import sys
from multiprocessing import Pool, Manager
from functools import partial
import random
import requests
import time
from threading import Thread
import collections


# Define
SERVER_PORT_LIST = [110, 143, 993, 995]
SMTP_PORT_LIST = [25, 465, 587]
WEB_PORT_LIST = [80, 443]

BUFSIZE = 1024
TIMEOUT = 1
ERR_BASE = 0
ERR_INVALID_ARGUMENT = ERR_BASE-1
MAX_PROCESSES_NUM = 20

# Analysis mode
simple_mode = 0
detail_mode = 1

# SSL default
SSL_context = ssl._create_unverified_context()
SSL_context.set_ciphers('DEFAULT')

# RE setting
MX_REGEX = "(mx\:)(\S+)(\s)"
A_REGEX = "(a\:)(\S+)(\s)"
IP4_REGEX = "(ip4\:)(\S+)(\s)"

# File
sevicerFile_lines = list()
sevicer_datas = list()
sevicerFile_url_lines = list()
sevicer_url_datas = list()

# Sevicer record
non_sevicer = {"MPOP3D", "Postfix", "Sendmail", "Dovecot", "none"}
sevicer = Manager().dict() # cache
sevicer_cnt = dict()


class ThreadWithReturnValue(Thread):
    def __init__(self, group=None, target=None, name=None,
                 args=(), kwargs={}, Verbose=None):
        Thread.__init__(self, group, target, name, args, kwargs)
        self._return = None

    def run(self):
        if self._target is not None:
            self._return = self._target(*self._args, **self._kwargs)

    def join(self, *args):
        Thread.join(self, *args)
        return self._return


def remove_prefix(string, prefix):
    if re.search(prefix + '*', string, re.I):
        return string[len(prefix):]
    return string


def get_html(url):
    try:
        r = requests.get(url, headers={"Content-Type": "application/json"}, allow_redirects=True, timeout=0.5)
        html = r.text
    except:
        html = ''
    return html


# --------------------
# About sevicer analysis
def sevicer_analysis(
        domain,
        port_list):
    global sevicer, non_sevicer
    sevicer_result = set()
    unrecognized_mess = set()
    analysis_result = set()
    ip_connected = set()
    web_page = dict()

    if sevicer.get(domain) != None:
        sevicer_result.add(sevicer[domain])
        if analysis_mode == simple_mode:
            print("重複資料")
            return (sevicer[domain], "重複資料", web_page)

    # get dns data
    dns_data = find_dns_data(domain)

    threads = dict()
    for data in dns_data:
        find = False
        segment = str(data).rsplit('.', 1)[0]
        for sevicer_url_data in sevicer_url_datas:
            # find it is match sevicer regex or not
            for i in range(1, len(sevicer_url_data)):
                if re.search(sevicer_url_data[i], data, re.I):
                    web_page['http://' + str(data)] = str(sevicer_url_data[0])
                    sevicer.update({str(domain): str(sevicer_url_data[0])})
                    sevicer.update({segment: str(sevicer_url_data[0])})
                    sevicer_result.add(sevicer_url_data[0])
                    if analysis_mode == simple_mode:
                        print("第一次發現")
                        return (sevicer_url_data[0], "第一次發現", web_page)
                    find = True
                    break
            if find:
                continue
        threads[str(data)] = ThreadWithReturnValue(target=get_html, args=('http://' + data,))
        threads[str(data)].start()

    for data in dns_data:
        segment = str(data).rsplit('.', 1)[0]
        if sevicer.get(segment) != None:
            sevicer_result.add(sevicer[segment])
            if analysis_mode == simple_mode:
                print("重複資料")
                return (sevicer[segment], "重複資料", web_page)
        isConnect = False
        analysis_result.clear()

        host = str(data)

        # check web_page
        html = threads[str(data)].join()
        html = str(html).replace('\n', '')

        if html != '':
            web_page['http://' + str(host)] = html

        for sevicer_data in sevicer_datas:
            # find it is match sevicer regex or not
            for i in range(1, len(sevicer_data)):
                if sevicer_data[0] in ['Google', 'Microsoft']:
                    continue
                if re.search(sevicer_data[i], html, re.I):
                    web_page['http://' + str(host)] = str(sevicer_data[0])
                    sevicer.update({str(domain): str(sevicer_data[0])})
                    sevicer.update({segment: str(sevicer_data[0])})
                    sevicer_result.add(sevicer_data[0])
                    if analysis_mode == simple_mode:
                        print("第一次發現")
                        return (sevicer_data[0], "第一次發現", web_page)

        for port in port_list:
            server_msg = try_connect(host, port)
            # check ip_connected
            if server_msg is not None:
                ip_connected.add(data)
            if (server_msg == None) or (len(server_msg) == 0):
                continue
            isConnect = True
            # handle sevicer regex
            current_sevicer = None
            for sevicer_data in sevicer_datas:
                # find it is match sevicer regex or not
                for i in range(1, len(sevicer_data)):
                    if (re.search(sevicer_data[i], server_msg, re.I)):
                        current_sevicer = sevicer_data[0]
                        break
                if current_sevicer != None:
                    break
            # check
            if (current_sevicer == None):
                unrecognized_mess.add(server_msg)
                continue
            analysis_result.add(current_sevicer)

        # check
        if not isConnect:
            continue

        sevicer_result = sevicer_result.union(analysis_result)
        if analysis_result:
            if analysis_mode == simple_mode:
                real_sevicer = list(sevicer_result - non_sevicer)
                if len(real_sevicer) > 0:
                    sevicer.update({str(domain): str(real_sevicer[0])})
                    sevicer.update({segment: str(real_sevicer[0])})
                    print("第一次發現")
                    return (real_sevicer[0], "第一次發現", web_page)

    if len(ip_connected) == 0:
        ip_connected = "( ´•̥̥̥ω•̥̥̥` ) 沒有任何連線 ( ´•̥̥̥ω•̥̥̥` )"

    if len(sevicer_result) > 0:
        print("最後結果")
        return (sevicer_result, ip_connected, web_page)

    unrecognized_mess = list(unrecognized_mess) if len(unrecognized_mess) > 0 else "Server No Message."
    print("無法判別")
    return (unrecognized_mess, ip_connected, web_page)


# --------------------
# About domain search MX, A and TXT
def find_dns_data(domain):
    dns_data = set()

    # handle MX
    try:
        dns_search_result = dns.resolver.query(domain, "MX")
        for item in dns_search_result:
            dns_data.add(str(item.exchange))
    except:
        pass

    # handle A
    try:
        dns_search_result = dns.resolver.query(domain, "A")
        for item in dns_search_result:
            dns_data.add(str(item))
    except:
        pass

    # handle TXT
    try:
        dns_search_result = dns.resolver.query(domain, "TXT")
        # each TXT data
        for line in dns_search_result:
            regex_search_result = re.findall(MX_REGEX, str(line))
            regex_search_result += re.findall(A_REGEX, str(line))
            regex_search_result += re.findall(IP4_REGEX, str(line))

            # check
            if not regex_search_result:
                continue
            # each regex result
            for item in regex_search_result:
                if ("/" not in item[1]):
                    dns_data.add(str(item[1]))
    except:
        pass

    return dns_data


# --------------------
# About socket connect
def try_connect(server_address, server_port):
    try:
        # general connect
        result = connect_server(server_address, server_port)
        return result
    except:
        try:
            # ssl connect
            result = connect_server(server_address, server_port, enable_ssl=True)
            return result
        except:
            pass
    return None


def connect_server(server_address, server_port, enable_ssl=False):
    Socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    Socket.settimeout(TIMEOUT)
    if (enable_ssl == True):
        Socket = SSL_context.wrap_socket(Socket, server_hostname=server_address)
    Socket.connect((server_address, server_port))
    server_msg = Socket.recv(BUFSIZE)
    server_msg = server_msg.decode().replace('\n', '').replace('\r', '')
    Socket.close()
    return server_msg


def read_file(file):
    global sevicerFile, sevicer_list, sevicerFile_lines, sevicer_datas, sevicerFile_url_lines, sevicer_url_datas
    sevicer_list = set()
    read_mode = 'response'

    with open("analysis_data.txt", 'r', encoding='UTF-8') as sevicerFile:
        for line in sevicerFile:
            if read_mode == 'response':
                if line[0] == '=':
                    read_mode = 'url'
                    continue
                if line[0] != '#':
                    sevicerFile_lines.append(line)
                    sevicer_list.add(line.replace("\n", "").split('\t')[0])
            elif read_mode == 'url':
                if line[0] != '#':
                    sevicerFile_url_lines.append(line)
                    sevicer_list.add(line.replace("\n", "").split('\t')[0])

    for line in sevicerFile_lines:
        sevicer_datas.append(line.replace("\n", "").split('\t'))
    for line in sevicerFile_url_lines:
        sevicer_url_datas.append(line.replace("\n", "").split('\t'))

    sevicer_list = list(sevicer_list - non_sevicer)
    # print(sevicer_list)

    with open(file, "r", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile)
        comp_list = list(reader)
    return comp_list


def analyze_one_data(comp, port_list, mode='MAIL', analysis_mode=simple_mode):
    # print(random.choice(['( @ \" v \" @ )', 'O ( ≧ v ≦ ) O', 'O ( ∩ _ ∩ ) O', '∩ ( • 8 • ) ∩']))
    if mode == 'MAIL':
        return sevicer_analysis(domain=comp[column_list['電子郵件信箱']].split('@')[-1],
                                port_list=port_list)
    elif mode == 'WEB': # 官網
        return sevicer_analysis(domain=remove_prefix(remove_prefix(remove_prefix(comp[column_list['網址']], 'https://'), 'http://'), 'www.').split('/')[0],
                                port_list=port_list)


def analysis_and_output(comp_list, attr_list):
    global column_list, server_analysis_results, gateway_analysis_results
    column_list = Manager().dict()

    for attr in attr_list:
        column = -1
        for comp in comp_list[0]:
            column += 1
            if attr == comp:
                column_list[attr] = column
                break
    del comp_list[0]

    with Pool(processes=MAX_PROCESSES_NUM) as p:
        server_analysis_results, ip_connected_list, web_pages = [], [], []
        comp_list_chunks = [comp_list[i:i + MAX_PROCESSES_NUM] for i in range(0, len(comp_list), MAX_PROCESSES_NUM)]
        complete_cnt = 0
        for comp_list_chunk in comp_list_chunks:
            res = p.map(partial(analyze_one_data, port_list=SERVER_PORT_LIST), comp_list_chunk)
            server_analysis_results += [data[0] for data in res]
            ip_connected_list += [data[1] for data in res]
            web_pages += [data[2] for data in res]
            print('---------------------------------------------------------------')
            complete_cnt += len(comp_list_chunk)
            print('complete :', complete_cnt)
            print('---------------------------------------------------------------')

        # gateway_analysis_results = p.map(partial(analyze_one_data, port_list=SMTP_PORT_LIST), comp_list) # 網關
        # gateway_analysis_results = [data[0] for data in gateway_analysis_results]
        # website_server_results = p.map(partial(analyze_one_data, port_list=SERVER_PORT_LIST, mode='WEB'), comp_list) # 官網

    with open('output.csv', 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f)
        writer.writerow(['公司名稱', '電子郵件信箱', '伺服器廠商名稱', '伺服器連線情況', '網域網頁內容'])
        for comp, server, connected_ip, web_page in zip(comp_list, server_analysis_results, ip_connected_list, web_pages):
            web_page_list = [(k, v) for k, v in web_page.items()]
            writer.writerow([comp[column_list['公司名稱']],
                             comp[column_list['電子郵件信箱']].split(';')[-1],
                             server,
                             connected_ip] +
                             web_page_list)

    '''
    with open('output.csv', 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f)
        writer.writerow(['公司名稱', '電子郵件信箱', '伺服器廠商名稱', '網關廠商名稱', '網址', '網址伺服器廠商名稱'])
        for comp, server, gateway, web_server in zip(comp_list, server_analysis_results, gateway_analysis_results, website_server_results):
            writer.writerow([comp[column_list['公司名稱']],
                             comp[column_list['電子郵件信箱']].split(';')[-1],
                             server,
                             gateway,
                             comp[column_list['網址']],
                             web_server])
    '''

def count_output():
    recognized_sevicer_cnt, no_mess_cnt = 0, 0
    unrecognized_sevicer_cnt, undiscovered_sevicer_cnt, discriminated_sevicer_cnt = 0, 0, 0
    global sevicer_cnt, analysis_mode

    for analysis_result in server_analysis_results:
        if analysis_result == "Server No Message.":
            no_mess_cnt += 1
        elif isinstance(analysis_result, list):
            undiscovered_sevicer_cnt += 1
        else:
            if analysis_mode == simple_mode:
                current_sevicers = [str(analysis_result).split(',')[0]]
            else:
                current_sevicers = analysis_result
            for current_sevicer in current_sevicers:
                recognized = False
                if current_sevicer in sevicer_list:
                    recognized = True
                    discriminated_sevicer_cnt += 1
                    if sevicer_cnt.get(current_sevicer) == None:
                        sevicer_cnt[current_sevicer] = 1
                    else:
                        sevicer_cnt[current_sevicer] += 1
            if recognized:
                recognized_sevicer_cnt += 1
            else:
                unrecognized_sevicer_cnt += 1

    analysis_mode = '簡單模式' if analysis_mode == simple_mode else '詳細模式'
    print('\n\n分析模式 :', analysis_mode, sep=' ', end='\n\n')
    print('總公司數 :', len(comp_list), end='\n\n')
    print('目前未判別出廠商公司數(無法判斷之訊息) : {} / {} ({}%)'.format(
        (undiscovered_sevicer_cnt), len(comp_list),
        round(undiscovered_sevicer_cnt / len(comp_list) * 100, 2)))
    print('無訊息之公司數 : {} / {} ({}%)'.format(
        (no_mess_cnt), len(comp_list),
        round(no_mess_cnt / len(comp_list) * 100, 2)))
    print('目前已處理廠商公司數(含不確定) : {} / {} ({}%)'.format(
        (recognized_sevicer_cnt + unrecognized_sevicer_cnt), len(comp_list),
        round((recognized_sevicer_cnt + unrecognized_sevicer_cnt) / len(comp_list) * 100, 2)))
    print('目前已判別出廠商公司數(不含不確定) : {} / {} ({}%)'.format(
        recognized_sevicer_cnt, len(comp_list),
        round(recognized_sevicer_cnt / len(comp_list) * 100, 2)))
    sevicer_cnt = sorted(sevicer_cnt.items(), key=lambda kv: kv[1], reverse=True)
    sevicer_cnt = collections.OrderedDict(sevicer_cnt)
    print('個別郵件廠商家數及比例 :')
    for sevicer, value in sevicer_cnt.items():
        print('\t{} : {} / {} ({}%)'.format(
            sevicer, value, discriminated_sevicer_cnt,
            round(value / discriminated_sevicer_cnt * 100, 2)))


if __name__ == "__main__":
    start_time = time.time()
    filename = sys.argv[1]
    attr_list = ["公司名稱", "電子郵件信箱", "網址"]
    global analysis_mode
    analysis_mode = int(sys.argv[2])

    comp_list = read_file(filename)
    analysis_and_output(comp_list, attr_list)
    count_output()

    print("\n--- %s seconds ---" % (time.time() - start_time))
