import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "eu-central-1" });
const replaceAll = (str, find, replace) => str.replace(new RegExp(find, "g"), replace);

export const handler = async (event) => {
  const body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
  const id = replaceAll(body.title, " ", "-").toLowerCase();
  const item = {
    TableName: "roman-dev-courses",
    Item: {
      id:        { S: id },
      title:     { S: body.title },
      watchHref: { S: `http://www.pluralsight.com/courses/${id}` },
      authorId:  { S: body.authorId },
      length:    { S: body.length },
      category:  { S: body.category },
    }
  };

  try {
    await client.send(new PutItemCommand(item));
    return {
      statusCode: 200,
      headers: {
        "Content-Type":                "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ message: "Course saved", id }),
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
