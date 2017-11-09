#change IP address accordingly
IP_ADDRESS=172.17.0.1
HTTP_PORT_IS=9764
HTTPS_PORT_IS=9444
HTTP_PORT_APIM=80
HTTPS_PORT_APIM=443
SYNAPSE_PORT=8243
USERNAME=admin
PASSWORD=admin
#Change application name everytime
APPLICATION_NAME=sample44
PRODUCTION=PRODUCTION
UN=_
SERVICE_PROVIDER_NAME="$USERNAME$UN$APPLICATION_NAME$UN$PRODUCTION"

#install jq from below URL
#http://xmodulo.com/how-to-parse-json-string-via-command-line-on-linux.html

echo "..............String Dynamic Client Registration.............."
cmd=$(curl -X POST -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: application/json" -d @initial_token.json http://$IP_ADDRESS:$HTTP_PORT_APIM/client-registration/v0.11/register)
clientId=$(echo $cmd | jq -r '.clientId')
clientSecret=$(echo $cmd | jq -r '.clientSecret')
echo "Client ID from Dynamic Client Reg: $clientId"
echo "Client Secret from Dynamic Client Reg: $clientSecret"
echo $cmd


echo "..............Getting Initial Access Token.............."
cmd=$(curl -v -X POST --basic -u $clientId:$clientSecret -H "Content-Type:application/x-www-form-urlencoded;charset=UTF-8" -k -d "grant_type=password&username=admin&password=admin&scope=apim:subscribe openid" https://$IP_ADDRESS:$SYNAPSE_PORT/token)
access_token=$(echo $cmd | jq -r '.access_token')
echo $cmd
echo "Initial Access Token: $access_token"


echo "..............Adding new Application.............."
sed -i "s/NAME/$APPLICATION_NAME/g" create_application.json
cmd=$(curl -k -H "Authorization: Bearer $access_token" -H "Content-Type: application/json" -X POST -d @create_application.json "https://$IP_ADDRESS:$HTTPS_PORT_APIM/api/am/store/v0.11/applications")
sed -i "s/$APPLICATION_NAME/NAME/g" create_application.json
applicationId=$(echo $cmd | jq -r '.applicationId')
echo "Application ID: $applicationId"


echo "..............Genarate Client ID/Secret to Service Provider.............."
cmd=$(curl -k -H "Authorization: Bearer $access_token" -H "Content-Type: application/json" -X POST -d @genarate_keys.json "https://$IP_ADDRESS:$HTTPS_PORT_APIM/api/am/store/v0.11/applications/generate-keys?applicationId=$applicationId")
consumerKey=$(echo $cmd | jq -r '.consumerKey')
consumerSecret=$(echo $cmd | jq -r '.consumerSecret')
echo "Service Provider Consumer Key: $consumerKey"
echo "Service Provider Consumer Secret: $consumerSecret"
echo $cmd


echo "..............Update Application to Authorization Code grant type .............."
cmd=$(curl -k -H "Authorization: Bearer $access_token" -H "Content-Type: application/json" -X PUT -d @update_grants.json "https://$IP_ADDRESS:$HTTPS_PORT_APIM/api/am/store/v0.11/applications/$applicationId/keys/PRODUCTION")
supportedGrantTypes=$(echo $cmd | jq -r '.supportedGrantTypes')
echo "Supported Grant Types: $supportedGrantTypes"


echo "..............Update Claim Configuration of Service Provider.............."
echo $SERVICE_PROVIDER_NAME
sed -i "s/SERVICE_PROVIDER_NAME/$SERVICE_PROVIDER_NAME/g" get_sp.xml
cmd=$(curl -k -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml;charset=UTF-8" -H "SOAPAction:urn:getApplication" -d @get_sp.xml "https://$IP_ADDRESS:$HTTPS_PORT_IS/services/IdentityApplicationManagementService?wsdl")
sed -i "s/$SERVICE_PROVIDER_NAME/SERVICE_PROVIDER_NAME/g" get_sp.xml
cp /dev/null get_sp_reponse.xml
echo $cmd >> get_sp_reponse.xml
applicationID=$(grep -oP '(?<=ax2199:applicationID>)[^<]+' "get_sp_reponse.xml")
echo "Service Provider Application ID: $applicationID"
echo $cmd

sed -i "s/SERVICE_PROVIDER_ID/$applicationID/g" update_sp_claims.xml
sed -i "s/SERVICE_PROVIDER_NAME/$SERVICE_PROVIDER_NAME/g" update_sp_claims.xml
cmd=$(curl -k -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml;charset=UTF-8" -H "SOAPAction:urn:updateApplication" -d @update_sp_claims.xml "https://$IP_ADDRESS:$HTTPS_PORT_IS/services/IdentityApplicationManagementService?wsdl")
sed -i "s/$applicationID/SERVICE_PROVIDER_ID/g" update_sp_claims.xml
sed -i "s/$SERVICE_PROVIDER_NAME/SERVICE_PROVIDER_NAME/g" update_sp_claims.xml
echo $cmd




