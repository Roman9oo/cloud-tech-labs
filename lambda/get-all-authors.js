const AWS = require("aws-sdk");

const dynamodb = new AWS.DynamoDB({
  region: "eu-central-1",
  apiVersion: "2012-08-10"
});

exports.handler = async (event) => {
  const params = {
    TableName: "roman-dev-authors"
  };

  try {
    const data = await dynamodb.scan(params).promise();
    const authors = data.Items.map(item => ({
      id: item.id.S,
      firstName: item.firstName.S,
      lastName: item.lastName.S
    }));

    return {
      statusCode: 200,
      body: JSON.stringify(authors)
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify(err)
    };
  }
};
