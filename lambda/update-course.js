const AWS = require("aws-sdk");

const dynamodb = new AWS.DynamoDB({
  region: "eu-central-1",
  apiVersion: "2012-08-10"
});

exports.handler = async (event) => {
  const params = {
    TableName: "roman-dev-courses",
    Item: {
      id: { S: event.id },
      title: { S: event.title },
      watchHref: { S: event.watchHref },
      authorId: { S: event.authorId },
      length: { S: event.length },
      category: { S: event.category }
    }
  };

  try {
    await dynamodb.putItem(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(params.Item)
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify(err)
    };
  }
};
