import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "eu-central-1" });

export const handler = async (event) => {
  try {
    const { id } = event.pathParameters;
    const data = await client.send(new GetItemCommand({
      TableName: "roman-dev-courses",
      Key: { id: { S: id } }
    }));
    const course = {
      id:        data.Item.id.S,
      title:     data.Item.title.S,
      watchHref: data.Item.watchHref.S,
      authorId:  data.Item.authorId.S,
      length:    data.Item.length.S,
      category:  data.Item.category.S,
    };
    return {
      statusCode: 200,
      headers: {
        "Content-Type":                "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(course),
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
