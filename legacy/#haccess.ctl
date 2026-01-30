# -FrontPage-

IndexIgnore #haccess.ctl */.??* *~ *# */HEADER* */README* */_vti*

<Limit GET POST>
order deny,allow
deny from all
allow from all
</Limit>
<Limit PUT>
order deny,allow
deny from all
</Limit>
AuthName nav_repository
AuthUserFile c:/frontpage\ webs/content/nav_repository/_vti_pvt/service.pwd
AuthGroupFile c:/frontpage\ webs/content/nav_repository/_vti_pvt/service.grp
