const AWS = require("aws-sdk");

const dynamodb = new AWS.DynamoDB({
  region: "eu-central-1",
  apiVersion: "2012-08-10"
});

const replaceAll = (str, find, replace) => {
  return str.replace(new RegExp(find, "g"), replace);
};

exports.handler = async (event) => {
  const id = replaceAll(event.title, " ", "-").toLowerCase();

  const params = {
    TableName: "roman-dev-courses",
    Item: {
      id: { S: id },
      title: { S: event.title },
      watchHref: { S: `http://www.pluralsight.com/courses/${id}` },
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
