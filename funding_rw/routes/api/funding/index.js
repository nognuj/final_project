'use strict'

module.exports = async function (fastify, opts) {

  // GET -> /api/fundings
  fastify.get('/', async function (request, reply) {
    
    try{
       // db connection
      const connection = await fastify.mysql.getConnection();

      // 일단 추출
      const funding_list = await connection.query(
        `SELECT * FROM test.Funding`
      );

      connection.release();

      if (funding_list.length === 0) {
        reply.code(404).send({ error: 'FundingId not found' });
      } else {
      reply.code(200).send({ funding_list });
      }
    
    } catch (error) {
      console.error('Error:', error);
      reply.code(500).send({ error: 'Internal server error' });
    }
  });

  // GET -> /api/funding/:fundingId
  fastify.get('/:fundingId', async function (request, reply) {
    try {
     
      const fundingId = request.params.fundingId;
  
      
      const connection = await fastify.mysql.getConnection();
  
      
      const query = 'SELECT * FROM test.Funding WHERE fundingId = ?';
      const [funding] = await connection.execute(query, [fundingId]);
  
      connection.release();
  
      if (funding.length === 0) {
        reply.code(404).send({ error: 'FundingId not found' });
      } else {
        reply.code(200).send({ funding });
      }
    } catch (error) {
      console.error('Error:', error);
      reply.code(500).send({ error: 'Internal server error' });
    }
  });

  // POST -> /api/funding
  fastify.post('/', async function (request, reply) {
    
    try{
       // db connection
      const connection = await fastify.mysql.getConnection();
      const {title, description, fundingAmount, fundingGoal, minAmount, maxAmount} = request.body;
      const startDate = new Date('2023-06-25T09:00:00');
      const endDate = new Date('2023-07-25T15:30:00');
      const millisecondsPerDay = 1000 * 60 * 60 * 24;
      const durationInMilliseconds = endDate - startDate;
      const duration = Math.ceil(durationInMilliseconds / millisecondsPerDay);
      const createdAt = new Date();
      let status = 1; //funding is an inactive by default

     // Insert Data
     // fundingId is created automatically according to the database table
      const funding_list = await connection.query(
        `INSERT INTO test.Funding (title, description, duration, startDate, endDate, createdAt, status, fundingAmount,fundingGoal, minAmount, maxAmount)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,?)`,
         [title, description, duration, startDate, endDate, createdAt, status, fundingAmount,fundingGoal, minAmount, maxAmount]
      );

      connection.release();

      reply.code(201).send({ message: 'Funding created successfully' });

    } catch (error) {
      console.error('Error:', error);
      reply.code(500).send({ error: 'Internal server error' });
    }
  })

  // DELETE the data of a certain fundingId
  fastify.delete('/:fundingId', async function (request, reply) {
    try {
      const fundingId = request.params.fundingId;
  
      const connection = await fastify.mysql.getConnection();
  
      const query = 'DELETE FROM test.Funding WHERE fundingId = ?';
      const [result] = await connection.execute(query, [fundingId]);
  
      connection.release();
  
      if (result.affectedRows === 0) {
        reply.code(404).send({ error: 'FundingId not found' });
      } else {
        reply.code(200).send({ message: 'Funding deleted successfully' });
      }
    } catch (error) {
      console.error('Error:', error);
      reply.code(500).send({ error: 'Internal server error' });
    }
  });

  //PUT method for a certain funding proj
  fastify.put('/:fundingId', async function (request, reply) {
    try {
      const fundingId = request.params.fundingId;
      const { fundingAmount } = request.body;
  
      const connection = await fastify.mysql.getConnection();
      
      // update a funding amount
      const updatedQuery = 'UPDATE test.Funding SET fundingAmount = fundingAmount + ? WHERE fundingId = ?';
      const updatedData = await connection.execute(updatedQuery, [fundingAmount ,fundingId]);
      console.log("-------------------------------------------")
      console.log(updatedData)
      
      // get the updated funding amount
      const getQuery = 'SELECT fundingAmount FROM test.Funding WHERE fundingId = ?';
      const [result] = await connection.execute(getQuery, [fundingId]);
      const updatedAmount = result[0].fundingAmount;
      const fundingGoal = result[0].fundingGoal;

      // status is changed after updating the funding amount
      if (updatedAmount >= fundingGoal) {
        const StatusQuery = 'UPDATE test.Funding SET status = ? WHERE fundingId = ?';
        await connection.execute(StatusQuery, [0, fundingId]);
      }

      connection.release();
  
      if (result.affectedRows === 0) {
        reply.code(404).send({ error: 'FundingId not found' });
      } else {
        reply.code(200).send({ message: 'Funding updated successfully' });
      }
    } catch (error) {
      console.error('Error:', error);
      reply.code(500).send({ error: 'Internal server error' });
    }
  });
  
//--------------------------------------------------------------------------
  fastify.post('/createDB', async function (request, reply) {
    
    // db connection
    const connection = await fastify.mysql.getConnection()

    // query 작성
    const [rows, fields] = await connection.query(
      'CREATE TABLE test.test01(\
        id INT NOT NULL AUTO_INCREMENT,\
        name VARCHAR(255) NOT NULL,\
        email VARCHAR(255) NOT NULL,\
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, \
        updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP, \
        PRIMARY KEY (id), \
        UNIQUE KEY email (email)\
      );'
    )
    connection.release()
    // return rows[0]
  
    // Set the response status code
    reply.code(201);
    // Send the request body as the response
    return { ret: 'create table'};
  })



  fastify.post('/insert', async function (request, reply) {
    
    // db connection
    const connection = await fastify.mysql.getConnection()

    // 유저 추가
    const [rows, fields] = await connection.query(
      `INSERT INTO test.test01(name, email) VALUES('Cheolwon', 'abcd@email.com')`
    )
    connection.release()
    // return rows[0]


    console.log('fin');
  
    // Set the response status code
    reply.code(201);
    // Send the request body as the response
    return { ret: 'insert db'};
  })

  fastify.get('/get', async function (request, reply) {

    // db connection
    const connection = await fastify.mysql.getConnection()

    // 일단 추출
    const [id, name, email] = await connection.query(
      `SELECT * FROM test.test01`
    )
    connection.release()
  
    // Set the response status code
    reply.code(200);
    // Send the request body as the response
    return { port: 'funding_rw', ret: id};
  })

  fastify.post('/user', async function (request, reply) {

    // db connection
    const connection = await fastify.mysql.getConnection()

    // table을 지워버림
    await connection.query(
      `DROP TABLE test.test01`
    )
    connection.release()
  
    // Set the response status code
    reply.code(201);
    // Send the request body as the response
    return { ret : 'delete table' };
  })
}


