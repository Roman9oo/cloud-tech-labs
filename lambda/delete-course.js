const AWS = require("aws-sdk");

const dynamodb = new AWS.DynamoDB({
  region: "eu-central-1",
  apiVersion: "2012-08-10"
});

exports.handler = async (event) => {
  const params = {
    TableName: "roman-dev-courses",
    Key: {
      id: { S: event.id }
    }
  };

  try {
    await dynamodb.deleteItem(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Course deleted successfully" })
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify(err)
    };
  }
};
