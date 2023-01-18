import sqlite3
import csv


def search_version(product):
    cursor = cu.execute("SELECT DISTINCT Version FROM ProductRelease WHERE Product = ?", (product,))
    versions = []
    for i in cursor:
        versions.append(i[0])
    return versions


def search_product():
    cursor = cu.execute("SELECT DISTINCT Product FROM ProductRelease")
    products = []
    for i in cursor:
        products.append(i[0])
    return products


def insert(product, version, systemtype, servertype, name, os, link):
    cu.execute("INSERT INTO ProductRelease (Product, Version, SystemType, ServerType, Name, OS, Link) VALUES(?, ?, ?, "
               "?, ?, ?, ?)", (product, version, systemtype, servertype, name, os, link,))
    conn.commit()
    return cu.lastrowid


def delete(num):
    cu.execute("DELETE FROM ProductRelease WHERE Id=?", (num,))
    conn.commit()


def search_filter(query_filter):
    sql_str = "SELECT Id, Product, Version, SystemType, ServerType, Name, OS, Link FROM ProductRelease "
    where_field = ""
    where_value = []
    for key in query_filter:
        if query_filter[key] is None:
            continue
        elif query_filter[key] is not None:
            if where_field:
                where_field += "AND "
            where_field += "{}=? ".format(key)
            where_value.append(query_filter[key])
    if where_field:
        sql_str = sql_str + "WHERE " + where_field
        cursor = cu.execute(sql_str, (where_value))
    else:
        cursor = cu.execute(sql_str)
    result_list = []
    for i in cursor:
        result_dict = {"id": i[0], "product": i[1], "version": i[2], "systemtype": i[3], "servertype": i[4],
                       "name": i[5], "os": i[6], "link": i[7]}
        result_list.append(result_dict)
    return result_list


def update(id, query_filter):
    sql_str = "UPDATE ProductRelease SET "
    sql_str1 = "WHERE Id=?"
    where_field = ""
    where_value = []
    for key in query_filter:
        if query_filter[key] is None:
            continue
        elif query_filter[key] is not None:
            if where_field:
                where_field += ", "
            where_field += "{}=? ".format(key)
            where_value.append(query_filter[key])
    where_value.append(id)
    if where_field:
        sql_str = sql_str + where_field + sql_str1
        cu.execute(sql_str, (where_value))
    conn.commit()


def exportcsv(path, exfunc=None):
    with open(path, "w", newline="") as csvfile:
        fieldnames = ["product", "version", "systemtype", "servertype", "name", "os", "link"]
        csvwrite = csv.DictWriter(csvfile, fieldnames=fieldnames)
        search_result = {}
        cursor = search_filter(search_result)
        for i in cursor:
            if exfunc is not None:
                i = exfunc(i)
            if i["systemtype"] == 0:
                i["systemtype"] = ""
            csvwrite.writerow({"product": i["product"], "version": i["version"], "systemtype": i["systemtype"],
                               "servertype": i["servertype"], "name": i["name"], "os": i["os"], "link": i["link"]})
    csvfile.close()


def deletetable():
    try:
        cu.execute("DROP TABLE ProductRelease")
        conn.commit()
    except:
        pass


def createtable():
    listOfTables = cu.execute("SELECT NAME FROM sqlite_master WHERE type='table'AND NAME='ProductRelease'").fetchall()
    if listOfTables == []:
        cu.execute('''CREATE TABLE ProductRelease
                (Id INTEGER PRIMARY KEY AUTOINCREMENT,
                Product VARCHAR(32),
                Version VARCHAR(16),
                SystemType smallint,
                ServerType VARCHAR(16),
                Name VARCHAR(128),
                OS VARCHAR(32),
                Link VARCHAR(1024));''')


def imfunc(query_filter):
    link = query_filter[6]
    i = 0
    for i in range(len(link)):
        if link[i] == '/' and link[i+1] == 'P':
            break

    query_filter[6] = query_filter[6][i:]
    return query_filter


def importcsv(path, imfunc=None):
    f = open(path, "r", encoding="utf-8")
    for i in f.readlines():
        int_field = 0
        string = ""
        field = []
        if i[0] != "#" and i[0] != "<":
            string += i
        string = string.rstrip()
        if string == "":
            continue
        elif string != "":
            field = string.split(",")
            if imfunc is not None:
                field = imfunc(field)
            if field[2] != "":
                int_field = int(field[2])
            insert(field[0], field[1], int_field, field[3], field[4], field[5], field[6])
        conn.commit()
    f.close()


# Print
def pprint():
    x = {"Product": None, "Version": None, "Systemtype": None, "ServerType": None, "Name": None, "OS": None,
         "Link": None}
    cursor = search_filter(x)
    for i in cursor:
        print(i)


# Open database connection
conn = sqlite3.connect("files.db", check_same_thread=False)
cu = conn.cursor()


def dbInit():
    print("Opened database successfully")
    deletetable()
    createtable()
    importcsv("/disk1/htdocs/files.txt", imfunc)

