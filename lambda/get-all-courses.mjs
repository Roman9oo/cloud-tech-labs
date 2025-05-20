import { DynamoDBClient, ScanCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "eu-central-1" });

export const handler = async () => {
  try {
    const data = await client.send(new ScanCommand({ TableName: "roman-dev-courses" }));
    const courses = data.Items.map(item => ({
      id:        item.id.S,
      title:     item.title.S,
      watchHref: item.watchHref.S,
      authorId:  item.authorId.S,
      length:    item.length.S,
      category:  item.category.S,
    }));
    return {
      statusCode: 200,
      headers: {
        "Content-Type":                "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(courses),
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      headers: {
        "Content-Type":                "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ error: err.message }),
    };
  }
};
