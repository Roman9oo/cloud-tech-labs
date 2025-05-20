import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "eu-central-1" });

export const handler = async (event) => {
  const body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
  const id   = event.pathParameters.id;

  const params = {
    TableName: "roman-dev-courses",
    Key:       { id: { S: id } },
    AttributeUpdates: {
      title:     { Action: "PUT", Value: { S: body.title }},
      watchHref: { Action: "PUT", Value: { S: body.watchHref }},
      authorId:  { Action: "PUT", Value: { S: body.authorId }},
      length:    { Action: "PUT", Value: { S: body.length }},
      category:  { Action: "PUT", Value: { S: body.category }},
    }
  };

  try {
    const result = await client.send(new UpdateItemCommand(params));
    return {
      statusCode: 200,
      headers: {
        "Content-Type":                "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ message: "Course updated", attributes: result.Attributes }),
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
