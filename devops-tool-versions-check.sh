# Check DevOps tool versions afer runnnng 'devops-tool-version-check.sh' script

echo "-------------------------------------"
echo "Check Java version:"
java -version

echo "-------------------------------------"
echo "Check Jenkins version:"
jenkins --version

echo "-------------------------------------"
echo "Check AWS CLI version:"
aws --version

echo "-------------------------------------"
echo "Check kubectl version:"
kubectl version --client

echo "-------------------------------------"
echo "Check Helm version:"
helm version --short

echo "-------------------------------------"
echo "Check Docker version:"
docker --version
echo "-------------------------------------"

echo "-------------------------------------"
echo "Check Docker version:"
docker --version
echo "-------------------------------------"

echo "-------------------------------------"
echo "Check Maven version:"
mvn -v
echo "-------------------------------------"


