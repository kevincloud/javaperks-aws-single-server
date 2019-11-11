#!/bin/bash

# Add LDAP Data

# add customers group
sudo bash -c "cat >/root/ldap/customers.ldif" <<EOF
dn: ou=Customers,dc=javaperks,dc=local
objectClass: organizationalUnit
ou: Customers
EOF

# Add customer #1 - Janice Thompson
sudo bash -c "cat >/root/ldap/janice_thompson.ldif" <<EOF
dn: cn=Janice Thompson,ou=Customers,dc=javaperks,dc=local
cn: Janice Thompson
sn: Thompson
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: jthomp4423@example.com
employeeNumber: CS100312
EOF

# Add customer #2 - James Wilson
sudo bash -c "cat >/root/ldap/james_wilson.ldif" <<EOF
dn: cn=James Wilson,ou=Customers,dc=javaperks,dc=local
cn: James Wilson
sn: Wilson
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: wilson@example.com
employeeNumber: CS106004
EOF

# Add customer #3 - Tommy Ballinger
sudo bash -c "cat >/root/ldap/tommy_ballinger.ldif" <<EOF
dn: cn=Tommy Ballinger,ou=Customers,dc=javaperks,dc=local
cn: Tommy Ballinger
sn: Ballinger
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: tommy6677@example.com
employeeNumber: CS101438
EOF

# Add customer #4 - Mary McCann
sudo bash -c "cat >/root/ldap/mary_mccann.ldif" <<EOF
dn: cn=Mary McCann,ou=Customers,dc=javaperks,dc=local
cn: Mary McCann
sn: McCann
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: mmccann1212@example.com
employeeNumber: CS210895
EOF

# Add customer #5 - Chris Peterson
sudo bash -c "cat >/root/ldap/chris_peterson.ldif" <<EOF
dn: cn=Chris Peterson,ou=Customers,dc=javaperks,dc=local
cn: Chris Peterson
sn: Peterson
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: cjpcomp@example.com
employeeNumber: CS122955
EOF

# Add customer #6 - Jennifer Jones
sudo bash -c "cat >/root/ldap/jennifer_jones.ldif" <<EOF
dn: cn=Jennifer Jones,ou=Customers,dc=javaperks,dc=local
cn: Jennifer Jones
sn: Jones
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: jjhome7823@example.com
employeeNumber: CS602934
EOF

# Add customer #7 - Clint Mason
sudo bash -c "cat >/root/ldap/clint_mason.ldif" <<EOF
dn: cn=Clint Mason,ou=Customers,dc=javaperks,dc=local
cn: Clint Mason
sn: Mason
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: clint.mason312@example.com
employeeNumber: CS157843
EOF

# Add customer #8 - Matt Grey
sudo bash -c "cat >/root/ldap/matt_grey.ldif" <<EOF
dn: cn=Matt Grey,ou=Customers,dc=javaperks,dc=local
cn: Matt Grey
sn: Grey
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: greystone89@example.com
employeeNumber: CS523484
EOF

# Add customer #9 - Howard Turner
sudo bash -c "cat >/root/ldap/howard_turner.ldif" <<EOF
dn: cn=Howard Turner,ou=Customers,dc=javaperks,dc=local
cn: Howard Turner
sn: Turner
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: runwayyourway@example.com
employeeNumber: CS658871
EOF

# Add customer #10 - Larry Olsen
sudo bash -c "cat >/root/ldap/larry_olsen.ldif" <<EOF
dn: cn=Larry Olsen,ou=Customers,dc=javaperks,dc=local
cn: Larry Olsen
sn: Olsen
objectClass: inetOrgPerson
userPassword: SuperSecret1
uid: olsendog1979@example.com
employeeNumber: CS103393
EOF

sudo bash -c "cat >/root/ldap/StoreUser.ldif" <<EOF
dn: cn=StoreUser,ou=Customers,dc=javaperks,dc=local
cn: StoreUser
objectClass: groupOfNames
member: cn=Janice Thompson,ou=Customers,dc=javaperks,dc=local
member: cn=James Wilson,ou=Customers,dc=javaperks,dc=local
member: cn=Tommy Ballinger,ou=Customers,dc=javaperks,dc=local
member: cn=Mary McCann,ou=Customers,dc=javaperks,dc=local
member: cn=Chris Peterson,ou=Customers,dc=javaperks,dc=local
member: cn=Jennifer Jones,ou=Customers,dc=javaperks,dc=local
member: cn=Clint Mason,ou=Customers,dc=javaperks,dc=local
member: cn=Matt Grey,ou=Customers,dc=javaperks,dc=local
member: cn=Howard Turner,ou=Customers,dc=javaperks,dc=local
member: cn=Larry Olsen,ou=Customers,dc=javaperks,dc=local
EOF

# Add LDAP data
# ldapadd -f /root/ldap/customers.ldif -h "10.0.1.224" -D "cn=admin,dc=javaperks,dc=local" -w SuperFuzz1
ldapadd -f /root/ldap/customers.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/janice_thompson.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/james_wilson.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/tommy_ballinger.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/mary_mccann.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/chris_peterson.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/jennifer_jones.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/clint_mason.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/matt_grey.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/howard_turner.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/larry_olsen.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}
ldapadd -f /root/ldap/StoreUser.ldif -h "${CLIENT_IP}" -D "${LDAP_ADMIN_USER}" -w ${LDAP_ADMIN_PASS}

service consul-template start
