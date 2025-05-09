#!/bin/bash
set -x
set -e
cd /app
[ -d venv ] || mkdir venv

cat << 'EOF' > /etc/yum.repos.d/Rocky-Devel.repo
# Rocky-Devel.repo
#

[devel]
name=Rocky Linux $releasever - Devel WARNING! FOR BUILDROOT AND KOJI USE
mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=Devel-$releasever
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/Devel/$basearch/os/
gpgcheck=1
enabled=0
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOF

cat << EOF > /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
-----BEGIN PGP PUBLIC KEY BLOCK-----
xsFNBGJ5RksBEADF/Lzssm7uryV6+VHAgL36klyCVcHwvx9Bk853LBOuHVEZWsme
kbJF3fQG7i7gfCKGuV5XW15xINToe4fBThZteGJziboSZRpkEQ2z3lYcbg34X7+d
co833lkBNgz1v6QO7PmAdY/x76Q6Hx0J9yiJWd+4j+vRi4hbWuh64vUtTd7rPwk8
0y3g4oK1YT0NR0Xm/QUO9vWmkSTVflQ6y82HhHIUrG+1vQnSOrWaC0O1lqUI3Nuo
b6jTARCmbaPsi+XVQnBbsnPPq6Tblwc+NYJSqj5d9nT0uEXT7Zovj4Je5oWVFXp9
P1OWkbo2z5XkKjoeobM/zKDESJR78h+YQAN9IOKFjL/u/Gzrk1oEgByCABXOX+H5
hfucrq5U3bbcKy4e5tYgnnZxqpELv3fN/2l8iZknHEh5aYNT5WXVHpD/8u2rMmwm
I9YTEMueEtmVy0ZV3opUzOlC+3ZUwjmvAJtdfJyeVW/VMy3Hw3Ih0Fij91rO613V
7n72ggVlJiX25jYyT4AXlaGfAOMndJNVgBps0RArOBYsJRPnvfHlLi5cfjVd7vYx
QhGX9ODYuvyJ/rW70dMVikeSjlBDKS08tvdqOgtiYy4yhtY4ijQC9BmCE9H9gOxU
FN297iLimAxr0EVsED96fP96TbDGILWsfJuxAvoqmpkElv8J+P1/F7to2QARAQAB
zU9Sb2NreSBFbnRlcnByaXNlIFNvZnR3YXJlIEZvdW5kYXRpb24gLSBSZWxlYXNl
IGtleSAyMDIyIDxyZWxlbmdAcm9ja3lsaW51eC5vcmc+wsGKBBMBCAA0BQJieUZL
FiEEIcslauFvxUxuZSlJcC1CbTUNJ10CGwMCHgECGQEDCwkHAhUIAxYAAgIiAQAK
CRBwLUJtNQ0nXWQ5D/9472seOyRO6//bQ2ns3w9lE+aTLlJ5CY0GSTb4xNuyv+AD
IXpgvLSMtTR0fp9GV3vMw6QIWsehDqt7O5xKWi+3tYdaXRpb1cvnh8r/oCcvI4uL
k8kImNgsx+Cj+drKeQo03vFxBTDi1BTQFkfEt32fA2Aw5gYcGElM717sNMAMQFEH
P+OW5hYDH4kcLbtUypPXFbcXUbaf6jUjfiEp5lLjqquzAyDPLlkzMr5RVa9n3/rI
R6OQp5loPVzCRZMgDLALBU2TcFXLVP+6hAW8qM77c+q/rOysP+Yd+N7GAd0fvEvA
mfeA4Y6dP0mMRu96EEAJ1qSKFWUul6K6nuqy+JTxktpw8F/IBAz44na17Tf02MJH
GCUWyM0n5vuO5kK+Ykkkwd+v43ZlqDnwG7akDkLwgj6O0QNx2TGkdgt3+C6aHN5S
MiF0pi0qYbiN9LO0e05Ai2r3zTFC/pCaBWlG1ph2jx1pDy4yUVPfswWFNfe5I+4i
CMHPRFsZNYxQnIA2Prtgt2YMwz3VIGI6DT/Z56Joqw4eOfaJTTQSXCANts/gD7qW
D3SZXPc7wQD63TpDEjJdqhmepaTECbxN7x/p+GwIZYWJN+AYhvrfGXfjud3eDu8/
i+YIbPKH1TAOMwiyxC106mIL705p+ORf5zATZMyB8Y0OvRIz5aKkBDFZM2QN6A==
=PzIf
-----END PGP PUBLIC KEY BLOCK-----
EOF
dnf config-manager --add-repo /etc/yum.repos.d/Rocky-Devel.repo
dnf config-manager --set-enabled devel

# provides openssl 3.0.7
cat << 'EOF' > /etc/yum.repos.d/Alma.repo
# Alma.repo
#

[alma]
name=Alma 9.4 Appstream
mirrorlist=https://mirrors.almalinux.org/mirrorlist/9.4/appstream
gpgcheck=1
enabled=0
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux9
[alma-base]
name= Alma 9.4 Baseos
mirrorlist=https://mirrors.almalinux.org/mirrorlist/9.4/baseos
EOF

cat << EOF > /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux9
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBGHmnykBEACuIcqcNYTmu2q58XI5NRZowdJGAxxs+6ExX7qsa4vbPp6St7lB
JmLpwf5p6czIBhLL4b8E7zJpu57tVDo7Ejw6Hv584rbI8vw7pnMTe6XUFhMTL8FT
lyAmn8xAIlcyM+SzshnxAc5b8E0p/egMonr3J1QnvMSfixMQ59GrmLVyece7Vv3J
4fREh6k31kg7eQdEkzRQhRdO2KyxWYLR0A6haXSXVaiBOjFF7iUs7anlJSfeD3FO
afPq0Ix8oWi+mUc4txkABMdsGpdkE/MHOwN90FB8EG5XVrdv3emm3yzKMMzb53Yd
jcf0fovIeRloQyl9+CrVCnkBjFcIFBZZddsB43kM7eTflmAQ+tanOZ8OKBRPMtmI
56b/vk31ozHUoST/NmjbEI5tu+QYCuFSZ++mC06qJg0Bkw821DTAsM7Kynuj7K2f
WWQjlDL9ZsFifLqDXRymL+sn6g142hHQOa5KSHtT7cAcrm6L48gEL3fPntVSOU/H
BlTnODiSSTIsIRNA7kBkbSP3wWoYC1JQPmNYbUtZ7va2uXNb9dGT2k7Ae0465WND
wqRQJDxsr6TLYFpti+JRaOpSMNclXz4kRSP263Y4ZzQvkMGgSgwqg7JU00Uahk2p
KTlJAA8AiaMBdShlo/QXvL29Lyg0Y5klq2HCNziJDupWhXto5j5pjixrpwARAQAB
tCdBbG1hTGludXggT1MgOSA8cGFja2FnZXJAYWxtYWxpbnV4Lm9yZz6JAk4EEwEI
ADgWIQS/GKwodheJCNbnEmfTbLhsuGs3FgUCYeafKQIbAwULCQgHAgYVCgkICwIE
FgIDAQIeAQIXgAAKCRDTbLhsuGs3FrvnD/9X1wDM/C214t3UVsMVjTLdIJDGG+iU
E7Uk7QGeyeNif19rRatzXUHBBGjiAwpxe2rkveWBHCHPSUKqsAR9Arv3nMKiaGfA
0nomzDndLEDIgv35xzaU6OhX95mZzvj+9PThuxDxUnsNoA+7vGkaiRw+cyyDdTJQ
bKwum8bx1gS8Kbqo9mqrMekQ4NHCodq9bb2hI6pAxlYa472QuwFAXFAzbE3LIMIK
hzLkew7nxwP0txP/zzqPw4lYN38fg9AlHL2qgf0twCFO4N/ftkw25qwoiBhiwaWT
Ca8Z9wUJx35Z/ufscbNrtRrIGYNXTDFJdGY/WxKDp7QsyOx/sclcsSksKoC/52tL
2yFLQrMXsqnLjAQajA6adaeCAAwvp2/8VP8R65O4KMuKghMneCGwXVlVVYyRUXJD
Kjg7EvmmMGuh/Lj2A/vj+mQMmlS2kAl0qOsK9DtUIA7Z9m98zI3UmN/5BMb/HdqW
KADagOW9IPyo6IaSIT+A+7npTN1Y7m1aIrL1vsAKrus4MrCvAs1vYqzqIikv88Di
EWYVFCWTsTWf7jxBCVTLn1Lr7Mj08i+7OgRgguQGpcnvKsbwq1v2whQrs+YKR9hP
vVaW5DmGJ5brPykJUaQS6p5Esp1q3HBk0HbBxiiGIwGsKbLp0pKsk5TLzMIJwIG/
lEolCV+fJ0P4nLkCDQRh5p8pARAAvXTL29arJ5Dl9FXVpE4Km1jJLaK2WfbQARJz
ygQKps9QNqS1yz7C7mYdTtgRxeK2eqcX5oA83w3ppJ0DTsxfAkY3nqAXS8+QRORU
ffSFvhdsU1G/qpvhX0Aq62gr4y1bkIMr9GlLq86uVKIQrNdmto4NDfQc1bDD5e4j
KaNMmNLXxq/s67AxFW/yLchYYZ7cMqQd6Ab4lacqpGdYFIAkBkVMmj3GUSo+FLpl
+4c50AZ8O0aB+xkrjch+4PoVyIpIC1IuqNYBYn2wMYFB414QY2iDopzpZXUhpCqx
NP4Zyhl1noUcOtH/wUfH1JsIcYRn0ixWF6JnE9KmjpkqBuM2/4Ot/bl67iPiN/if
vf3Z1kYjNPaszoMW3kmJj8MlBCSH9w6nQRG/eikihbeUDBB6rh2O7Dz8ltFqlt8N
asbngRoNZMnWMnItRV67Fo0pfn/DZA8VvI029apE21sNp6l7MUa8Z2/I/PNq10E8
rPMQM//k9y2kgxz52i6iCyesobPvun6UC4xuFoYKUTQMgKQgqOhyZ4evkepFhmHg
Gzx+F8EmwN1FtxfNxfLtQZSUT3kxuUDizwpaH/LkSkRXpJOQyHJL6VBINNTjB4j1
3+0jD+lCV6xIt88NYkGJL9rtKwZLQHSDPiI0ooCJ69GKy8SmSx04AwSsY67In1q8
+FQjT20AEQEAAYkCNgQYAQgAIBYhBL8YrCh2F4kI1ucSZ9NsuGy4azcWBQJh5p8p
AhsMAAoJENNsuGy4azcW0KkP/i0YLRv+pDiSC4034oboczAnNrzJnBhqTi9cUEGn
Xpqvf/Zz3opqvRQiqZAgVcCtxfW+P9J3Vb/mBJ6OkR/jywAlY5il2dzK08YfVXmP
cEf6RF4M0KNtlYJmPlnQCZjMJaisrPmYD3Yy8ER1qJ5JQZ7n0REHZCbBCqH8w+5r
j4ohEHY7xXbd7+tvWTCk2MkHaide/UV/04WiO064AoZSUze/vaAx8Ll4AyFpxuIk
ktXZXbq7MaVzqYYJptiRB6TljzMwIbblLm9A7T7YTA/1rNe12OhDT8VoR3gG2C/l
Mtf37EmYq3QVqFlbj4+ouQWIiQmp5dQenH5ugf+Bob7IiENpxzF1cIu6wd4p5Y64
3cdYUoxrjhsCM6W1lSqECoN8yXJnRTxpBwwm65SVk477KS2h77aJfa+v5UnBhpSt
eVlAhs0A8Qp/hX3o7qMO1jWca3zdJwXppLlFEYTVaFUOUrc4Lhlbi0gAnn8aBwSx
xF1r5GhPGIBzHtRgulwZkmS6VwtDMuC6KlrASu9f93D5gLZqVk22Oar9LpgCEACd
8Gw/+BFbdANqo9IKmDrWf7k/YuEqZ3h+eoyKI/2z7dKh/fcVEydMTn3LB4nFRvSD
AZ27tvC0IUXCUNx7iJdrD5kDsMhZRl5/dXbe539G4y2W00QYuJC0DpUvGdtOuaFx
1WKL
=jk2t
-----END PGP PUBLIC KEY BLOCK-----
EOF

dnf config-manager --add-repo /etc/yum.repos.d/Alma.repo
dnf config-manager --set-enabled alma
dnf config-manager --set-enabled alma-base
# after seeing this error:
# https://forums.rockylinux.org/t/rhel-9-to-rocky-9-issue/14251
# try removing openssl-fips-provider
set +e
rpm -e openssl-fips-provider --nodeps
set -e
# tried a similar dnf command, but that didn't work. still wanted to remove systemd
# dnf --noautoremove remove openssl-fips-provider

dnf install -y --refresh --allowerasing openssl-devel-3.0.7 rust cargo gcc gcc-c++ make openssh-clients git pkgconf-pkg-config xmlsec1-devel libpq-devel libtool-ltdl-devel