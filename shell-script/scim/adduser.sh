IP_ADDRESS=172.18.0.1
HTTP_PORT_IS=9764
HTTPS_PORT_IS=9444
echo "..............Starting Create User .............."
cmd=$(curl -v -k --user admin:admin -d @create_user.json -H "Content-Type:application/json" https://$IP_ADDRESS:$HTTPS_PORT_IS/wso2/scim/Users)
echo "..............Create User Response.............."
echo $cmd

