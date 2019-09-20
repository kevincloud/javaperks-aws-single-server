import MySQLdb # pylint: disable=import-error
import sys
import hvac
import base64

dbname = sys.argv[1]
username = sys.argv[2]
password = sys.argv[3]
roottoken = sys.argv[4]
region = sys.argv[5]
vault = hvac.Client(url="http://vault-main.service."+region+".consul:8200", token=roottoken)

db = MySQLdb.connect(host = dbname,
                     user = username,
                     password = password)

cursor = db.cursor()

def encrypt_acct(data):
    retval = vault.secrets.transit.encrypt_data(
        mount_point = 'transit',
        name = 'account',
        plaintext = base64.b64encode(data.encode()).decode('ascii')
    )
    return retval['data']['ciphertext']

def encrypt_cc(data):
    retval = vault.secrets.transit.encrypt_data(
        mount_point = 'transit',
        name = 'payment',
        plaintext = base64.b64encode(data.encode()).decode('ascii')
    )
    return retval['data']['ciphertext']

sql = "create database if not exists javaperks"
x = cursor.execute(sql)

sql = "use javaperks"
x = cursor.execute(sql)

sql = """create table if not exists customer_main(
    custid int auto_increment,
    custno varchar(20) not null,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    email varchar(255) not null,
    dob varchar(255),
    ssn varchar(255),
    datecreated datetime,
    primary key (custid),
    index idx_custno (custno)
) engine=innodb
"""
x = cursor.execute(sql)

sql = """create table if not exists customer_addresses(
    addrid int auto_increment,
    custid int not null,
    contact varchar(255) not null,
    address1 varchar(150) not null,
    address2 varchar(150),
    city varchar(150) not null,
    state varchar(2) not null,
    zip varchar(20) not null,
    phone varchar(35),
    addrtype varchar(20),
    primary key(addrid),
    index idx_custid (custid),
    constraint fk_custid_custid
        foreign key (custid)
        references customer_main (custid)
) engine=innodb
"""
x = cursor.execute(sql)

sql = """create table if not exists customer_payment(
    payid int auto_increment,
    custid int not null,
    cardname varchar(255) not null,
    cardnumber varchar(255) not null,
    cardtype varchar(2),
    cvv varchar(255) not null,
    expmonth varchar(2) not null,
    expyear varchar(4) not null,
    primary key(payid),
    index idx_pay_custid (custid)
) engine=innodb
"""
x = cursor.execute(sql)

sql = """create table if not exists customer_invoice(
    invid int auto_increment,
    invno varchar(30) not null,
    custid int not null,
    invdate datetime not null,
    orderid varchar(30),
    title varchar(255) not null,
    amount decimal,
    tax decimal,
    shipping decimal,
    total decimal,
    datepaid datetime,
    contact varchar(255) not null,
    address1 varchar(150) not null,
    address2 varchar(150),
    city varchar(150) not null,
    state varchar(2) not null,
    zip varchar(20) not null,
    phone varchar(35),
    primary key(invid),
    index idx_inv_custid (custid)
) engine=innodb
"""
x = cursor.execute(sql)

sql = """create table if not exists customer_invoice_item(
    itemid int auto_increment,
    invid int not null,
    product varchar(255) not null,
    description text,
    amount decimal,
    quantity int,
    lineno int,
    primary key(itemid),
    index idx_invoice (invid)
) engine=innodb
"""
x = cursor.execute(sql)

##################################
# Add Customer 1 - Janice Thompson
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS100312', 
        'Janice', 
        'Thompson', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2016-05-01'
    )
""".format(
    email = encrypt_acct('jthomp4423@example.com'), 
    dob = encrypt_acct('11/28/1983'), 
    ssn = encrypt_acct('027-40-7057')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Janice Thompson', 
        '3611 Farland Street', 
        'Brockton', 
        'MA', 
        '02401', 
        '774-240-5996', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Janice Thompson', 
        '3611 Farland Street', 
        'Brockton', 
        'MA', 
        '02401', 
        '774-240-5996', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Janice Thompson', 
        '{cardnum}', 
        'AX', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('378282246310005'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 2 - James Wilson
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS106004', 
        'James', 
        'Wilson', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2013-07-06'
    )
""".format(
    email = encrypt_acct('wilson@example.com'), 
    dob = encrypt_acct('6/4/1974'), 
    ssn = encrypt_acct('309-64-5158')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'James Wilson', 
        '1437 Capitol Avenue', 
        'Paragon', 
        'IN', 
        '46166', 
        '765-537-0152', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'James Wilson', 
        '1437 Capitol Avenue', 
        'Paragon', 
        'IN', 
        '46166', 
        '765-537-0152', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'James Wilson', 
        '{cardnum}', 
        'AX', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('371449635398431'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 3 - Tommy Ballinger
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS101438', 
        'Tommy', 
        'Ballinger', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2016-12-28'
    )
""".format(
    email = encrypt_acct('tommy6677@example.com'), 
    dob = encrypt_acct('1/5/1984'), 
    ssn = encrypt_acct('530-02-6158')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Tommy Ballinger', 
        '2143 Wescam Court', 
        'Reno', 
        'NV', 
        '89502', 
        '775-856-9045', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Tommy Ballinger', 
        '2143 Wescam Court', 
        'Reno', 
        'NV', 
        '89502', 
        '775-856-9045', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Tommy Ballinger', 
        '{cardnum}', 
        'AX', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('378734493671000'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 4 - Mary McCann
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS210895', 
        'Mary', 
        'McCann', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2018-05-24'
    )
""".format(
    email = encrypt_acct('mmccann1212@example.com'), 
    dob = encrypt_acct('9/4/1981'), 
    ssn = encrypt_acct('246-98-9817')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Mary McCann', 
        '4512 Layman Avenue', 
        'Robbins', 
        'NC', 
        '27325', 
        '910-948-3965', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Mary McCann', 
        '4512 Layman Avenue', 
        'Robbins', 
        'NC', 
        '27325', 
        '910-948-3965', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Mary McCann', 
        '{cardnum}', 
        'DI', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('6011111111111117'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 5 - Chris Peterson
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS122955', 
        'Chris', 
        'Peterson', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2015-03-04'
    )
""".format(
    email = encrypt_acct('cjpcomp@example.com'), 
    dob = encrypt_acct('9/9/1975'), 
    ssn = encrypt_acct('019-26-9782')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Chris Peterson', 
        '2329 Joanne Lane', 
        'Newburyport', 
        'MA', 
        '01950', 
        '978-499-7306', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Chris Peterson', 
        '2329 Joanne Lane', 
        'Newburyport', 
        'MA', 
        '01950', 
        '978-499-7306', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Chris Peterson', 
        '{cardnum}', 
        'DI', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('6011000990139424'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 6 - Jennifer Jones
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS602934', 
        'Jennifer', 
        'Jones', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2014-10-17'
    )
""".format(
    email = encrypt_acct('jjhome7823@example.com'), 
    dob = encrypt_acct('10/31/1983'), 
    ssn = encrypt_acct('209-62-4365')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Jennifer Jones', 
        '589 Hidden Valley Road', 
        'Lancaster', 
        'PA', 
        '17670', 
        '717-224-9902', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Jennifer Jones', 
        '589 Hidden Valley Road', 
        'Lancaster', 
        'PA', 
        '17670', 
        '717-224-9902', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Jennifer Jones', 
        '{cardnum}', 
        'MC', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('5555555555554444'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 7 - Clint Mason
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS157843', 
        'Clint', 
        'Mason', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2014-08-23'
    )
""".format(
    email = encrypt_acct('clint.mason312@example.com'), 
    dob = encrypt_acct('10/7/1983'), 
    ssn = encrypt_acct('453-37-0205')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Clint Mason', 
        '3641 Alexander Drive', 
        'Denton', 
        'TX', 
        '76201', 
        '940-349-9386', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Clint Mason', 
        '3641 Alexander Drive', 
        'Denton', 
        'TX', 
        '76201', 
        '940-349-9386', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Clint Mason', 
        '{cardnum}', 
        'MC', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('5105105105105100'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 8 - Matt Grey
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS523484', 
        'Matt', 
        'Grey', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2016-11-12'
    )
""".format(
    email = encrypt_acct('greystone89@example.com'), 
    dob = encrypt_acct('7/25/1963'), 
    ssn = encrypt_acct('184-36-8146')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Matt Grey', 
        '1320 Tree Top Lane', 
        'Wayne', 
        'PA', 
        '19087', 
        '610-225-6567', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Matt Grey', 
        '1320 Tree Top Lane', 
        'Wayne', 
        'PA', 
        '19087', 
        '610-225-6567', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Matt Grey', 
        '{cardnum}', 
        'VS', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('4111111111111111'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 9 - Howard Turner
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS658871', 
        'Howard', 
        'Turner', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2014-03-03'
    )
""".format(
    email = encrypt_acct('runwayyourway@example.com'), 
    dob = encrypt_acct('6/29/1977'), 
    ssn = encrypt_acct('019-26-8577')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Howard Turner', 
        '1179 Lynn Street', 
        'Woburn', 
        'MA', 
        '01801', 
        '617-251-5420', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Howard Turner', 
        '1179 Lynn Street', 
        'Woburn', 
        'MA', 
        '01801', 
        '617-251-5420', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Howard Turner', 
        '{cardnum}', 
        'VS', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('4012888888881881'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

##################################
# Add Customer 10 - Larry Olsen
##################################

sql = """insert into customer_main(
        custno, 
        firstname, 
        lastname, 
        email,
        dob, 
        ssn, 
        datecreated
    ) values (
        'CS103393', 
        'Larry', 
        'Olsen', 
        '{email}', 
        '{dob}', 
        '{ssn}', 
        '2016-02-21'
    )
""".format(
    email = encrypt_acct('olsendog1979@example.com'), 
    dob = encrypt_acct('4/17/1992'), 
    ssn = encrypt_acct('285-70-8598')
)
x = cursor.execute(sql)

sql = "select last_insert_id()"
retval = cursor.execute(sql)
rset = cursor.fetchall()
nextid = rset[0][0]

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Larry Olsen', 
        '2850 Still Street', 
        'Oregon', 
        'OH', 
        '43616', 
        '419-698-9890', 
        'B'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_addresses(
        custid, 
        contact, 
        address1, 
        city, 
        state, 
        zip, 
        phone, 
        addrtype
    ) values (
        {id}, 
        'Larry Olsen', 
        '2850 Still Street', 
        'Oregon', 
        'OH', 
        '43616', 
        '419-698-9890', 
        'S'
    )
""".format(
    id = str(nextid)
)
x = cursor.execute(sql)

sql = """insert into customer_payment(
        custid, 
        cardname, 
        cardnumber, 
        cardtype, 
        cvv, 
        expmonth, 
        expyear
    ) values (
        {id}, 
        'Larry Olsen', 
        '{cardnum}', 
        'VS', 
        '{cvv}', 
        '08', 
        '2024'
    )
""".format(
    id = str(nextid), 
    cardnum = encrypt_cc('4111111111111111'),
    cvv = encrypt_cc('344')
)
x = cursor.execute(sql)

db.commit()
db.close()
