"use strict";
const axios = require("axios");

module.exports = async function (fastify, opts) {
  // GET -> /api/funding
  fastify.get("/", async function (request, reply) {
    try {
      // db connection
      const connection = await fastify.mysql.getConnection();

      const funding_list = await connection.query(`SELECT * FROM test.Funding`);

      connection.release();

      if (funding_list.length === 0) {
        reply.code(404).send({ error: "FundingId not found" });
      } else {
        reply.code(200).send({ funding_list });
      }
    } catch (error) {
      console.error("Error:", error);
      reply.code(500).send({ error: "Internal server error" });
    }
  });

  // GET -> /api/funding/:fundingId
  fastify.get("/:fundingId", async function (request, reply) {
    try {
      const fundingId = request.params.fundingId;

      const connection = await fastify.mysql.getConnection();

      const query = "SELECT * FROM test.Funding WHERE fundingId = ?";
      const [funding] = await connection.execute(query, [fundingId]);

      connection.release();

      if (funding.length === 0) {
        reply.code(404).send({ error: "FundingId not found" });
      } else {
        reply.code(200).send({ funding });
      }
    } catch (error) {
      console.error("Error:", error);
      reply.code(500).send({ error: "Internal server error" });
    }
  });

  // POST -> /api/funding
  fastify.post("/", async function (request, reply) {
    try {
      // db connection
      const connection = await fastify.mysql.getConnection();

      const {
        title,
        description,
        fundingAmount,
        fundingGoal,
        minAmount,
        maxAmount,
      } = request.body;
      const startDate = new Date("2023-06-25T09:00:00");
      const endDate = new Date("2023-07-25T15:30:00");
      const millisecondsPerDay = 1000 * 60 * 60 * 24;
      const durationInMilliseconds = endDate - startDate;
      const duration = Math.ceil(durationInMilliseconds / millisecondsPerDay);
      const createdAt = new Date();
      let status = 1; //funding is an inactive by default

      // Insert Data
      const funding_list = await connection.query(
        `INSERT INTO test.Funding (title, description, duration, startDate, endDate, createdAt, status, fundingAmount,fundingGoal, minAmount, maxAmount)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,?)`,
        [
          title,
          description,
          duration,
          startDate,
          endDate,
          createdAt,
          status,
          fundingAmount,
          fundingGoal,
          minAmount,
          maxAmount,
        ]
      );

      connection.release();

      reply.code(201).send({ message: "Funding created successfully" });
    } catch (error) {
      console.error("Error:", error);
      reply.code(500).send({ error: "Internal server error" });
    }
  });

  // DELETE the data of a certain fundingId
  fastify.delete("/:fundingId", async function (request, reply) {
    try {
      const fundingId = request.params.fundingId;

      const connection = await fastify.mysql.getConnection();

      const query = "DELETE FROM test.Funding WHERE fundingId = ?";
      const [result] = await connection.execute(query, [fundingId]);

      connection.release();

      if (result.affectedRows === 0) {
        reply.code(404).send({ error: "FundingId not found" });
      } else {
        reply.code(200).send({ message: "Funding deleted successfully" });
      }
    } catch (error) {
      console.error("Error:", error);
      reply.code(500).send({ error: "Internal server error" });
    }
  });

  //PUT method for a certain funding proj
  fastify.put("/:fundingId", async function (request, reply) {
    try {
      const API_GATEWAY_URL =
        "https://e87z0kfwe1.execute-api.ap-northeast-2.amazonaws.com/prod/broker";

      const fundingId = request.params.fundingId;
      const { fundingAmount } = request.body;

      const headers = {
        Auth: true,
      };
      const body = {
        destination: "goal_achivement",
        payload: {
          date: new Date(),
        },
      };

      const connection = await fastify.mysql.getConnection();

      // update a funding amount
      const updatedQuery =
        "UPDATE test.Funding SET fundingAmount = fundingAmount + ? WHERE fundingId = ?";
      await connection.execute(updatedQuery, [fundingAmount, fundingId]);

      // get the updated funding amount
      const getQuery = "SELECT * FROM test.Funding WHERE fundingId = ?";
      const [result] = await connection.execute(getQuery, [fundingId]);
      const updatedAmount = result[0].fundingAmount;
      console.log(updatedAmount);
      console.log(result[0]);
      const fundingGoal = result[0].fundingGoal;
      console.log(fundingGoal);
      // status is changed after updating the funding amount
      if (updatedAmount >= fundingGoal) {
        const StatusQuery =
          "UPDATE test.Funding SET status = ? WHERE fundingId = ?";
        await connection.execute(StatusQuery, [0, fundingId]);
        console.log("확인");
        await axios.post(API_GATEWAY_URL, body, { headers });
      }

      connection.release();

      if (result.affectedRows === 0) {
        reply.code(404).send({ error: "FundingId not found" });
      } else {
        reply.code(200).send({ message: "Funding updated successfully" });
      }
    } catch (error) {
      console.error("Error:", error);
      reply.code(500).send({ error: "Internal server error" });
    }
  });
};
