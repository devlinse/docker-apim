IP_ADDRESS=172.18.0.1
HTTP_PORT_IS=9764
HTTPS_PORT_IS=9444
USER_SCIM_ID=b6802827-3606-4d1a-9056-932517144503

echo "..............Starting Delete User .............."
cmd=$(curl -v -k --user admin:admin -X DELETE https://$IP_ADDRESS:$HTTP_PORT_IS/wso2/scim/Users/$USER_SCIM_ID -H "Accept: application/json")
echo "..............Delete User Response.............."
echo $cmd
