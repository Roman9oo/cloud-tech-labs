const AWS = require("aws-sdk");

const dynamodb = new AWS.DynamoDB({
  region: "eu-central-1",
  apiVersion: "2012-08-10"
});

exports.handler = async (event) => {
  const params = {
    TableName: "roman-dev-courses"
  };

  try {
    const data = await dynamodb.scan(params).promise();
    const courses = data.Items.map(item => ({
      id: item.id.S,
      title: item.title.S,
      watchHref: item.watchHref.S,
      authorId: item.authorId.S,
      length: item.length.S,
      category: item.category.S
    }));

    return {
      statusCode: 200,
      body: JSON.stringify(courses)
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify(err)
    };
  }
};
