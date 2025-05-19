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
    const data = await dynamodb.getItem(params).promise();
    if (!data.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: "Course not found" })
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        id: data.Item.id.S,
        title: data.Item.title.S,
        watchHref: data.Item.watchHref.S,
        authorId: data.Item.authorId.S,
        length: data.Item.length.S,
        category: data.Item.category.S
      })
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify(err)
    };
  }
};
