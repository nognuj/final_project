'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/funding read write ecs test입니다 last_test' }
  })

  //gahyun-funding added
  // GET -> /api/fundings
//   fastify.get('/api/funding', async function (request, reply) {
    
//     try{
//       //const funding = request.body;
//        // db connection
//       const connection = await fastify.mysql.getConnection();

//       // 일단 추출
//       const funding_list = await connection.query(
//         `SELECT * FROM test.Funding`
//       );

//       connection.release();

//       if (funding_list.length === 0) {
//         reply.code(404).send({ error: 'FundingId not found' });
//       } else {
//       reply.code(200).send({ funding_list });
//       }
    
//     } catch (error) {
//       console.error('Error:', error);
//       reply.code(500).send({ error: 'Internal server error' });
//     }
//   });

//   // GET -> /api/funding/:fundingId
//   fastify.get('/api/funding/:fundingId', async function (request, reply) {
//     try {
     
//       const fundingId = request.params.fundingId;
  
      
//       const connection = await fastify.mysql.getConnection();
  
      
//       const query = 'SELECT * FROM test.Funding WHERE fundingId = ?';
//       const [funding] = await connection.execute(query, [fundingId]);
  
//       connection.release();
  
//       if (funding.length === 0) {
//         reply.code(404).send({ error: 'FundingId not found' });
//       } else {
//         reply.code(200).send({ funding });
//       }
//     } catch (error) {
//       console.error('Error:', error);
//       reply.code(500).send({ error: 'Internal server error' });
//     }
//   });

//   // POST -> /api/funding
//   fastify.post('/api/funding', async function (request, reply) {
    
//     try{
//        // db connection
//       const connection = await fastify.mysql.getConnection();
//       // startDate and endDate 는 요청 바디에서 가져오지않고 임의로 정해줄꺼임.
//       const {title, description, fundingAmount, minAmount, maxAmount} = request.body;
//       const startData = new Date('2023-06-25T09:00:00');
//       const endData = new Date('2023-07-25T15:30:00');
//       const millisecondsPerDay = 1000 * 60 * 60 * 24;
//       const durationInMilliseconds = endData - startData;
//       const duration = Math.ceil(durationInMilliseconds / millisecondsPerDay);
//       const createdAt = new Date();
//       const status = 0; //funding is an inactive by default
//       // const currentDate = new Date ()
//       // if (currentDate >= startDate && currentDate <= endDate) {
//       //   status = 1 // during the period of funding, it's active
//       // } else {
//       //   status = 0 // otherwise
//       // }

//      // Insert Data
//      // fundingId is created automatically according to the database table
//       const funding_list = await connection.query(
//         `INSERT INTO test.Funding (title, description, duration, startDate, endDate, createdAt, status, fundingAmount, minAmount, maxAmount)
//          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
//          [title, description, duration, startData, endData, createdAt, status, fundingAmount, minAmount, maxAmount]
//       );

//       connection.release();

//       reply.code(201).send({ message: 'Funding created successfully' });

//     } catch (error) {
//       console.error('Error:', error);
//       reply.code(500).send({ error: 'Internal server error' });
//     }
//   })

//   // DELETE the data of a certain fundingId
//   fastify.delete('/api/funding/:fundingId', async function (request, reply) {
//     try {
//       const fundingId = request.params.fundingId;
  
//       const connection = await fastify.mysql.getConnection();
  
//       const query = 'DELETE FROM test.Funding WHERE fundingId = ?';
//       const [result] = await connection.execute(query, [fundingId]);
  
//       connection.release();
  
//       if (result.affectedRows === 0) {
//         reply.code(400).send({ error: 'FundingId not found' });
//       } else {
//         reply.code(200).send({ message: 'Funding deleted successfully' });
//       }
//     } catch (error) {
//       console.error('Error:', error);
//       reply.code(500).send({ error: 'Internal server error' });
//     }
//   });

//   // PUT method for a certain funding proj
// //   fastify.put('/api/funding', async function (request, reply) {
// //     try {
// //       const fundingId = request.params.fundingId;
  
// //       const connection = await fastify.mysql.getConnection();
  
// //       const query = 'UPDATE funding SET title = ?, description = ?, startDate = ?, endDate = ?, fundingAmount = ?, minAmount = ?, maxAmount = ? WHERE fundingId = ?';
// //       const [result] = await connection.execute(query, [title, description, startDate, endDate, fundingAmount, minAmount, maxAmount, fundingId]);
  
// //       connection.release();
  
// //       if (result.affectedRows === 0) {
// //         reply.code(400).send({ error: 'FundingId not found' });
// //       } else {
// //         reply.code(200).send({ message: 'Funding deleted successfully' });
// //       }
// //     } catch (error) {
// //       console.error('Error:', error);
// //       reply.code(500).send({ error: 'Internal server error' });
// //     }
// //   });
  
// // //--------------------------------------------------------------------------
//   fastify.post('/createDB', async function (request, reply) {
    
//     // db connection
//     const connection = await fastify.mysql.getConnection()

//     // query 작성
//     const [rows, fields] = await connection.query(
//       'CREATE TABLE test.test01(\
//         id INT NOT NULL AUTO_INCREMENT,\
//         name VARCHAR(255) NOT NULL,\
//         email VARCHAR(255) NOT NULL,\
//         created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, \
//         updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP, \
//         PRIMARY KEY (id), \
//         UNIQUE KEY email (email)\
//       );'
//     )
//     connection.release()
//     // return rows[0]
  
//     // Set the response status code
//     reply.code(201);
//     // Send the request body as the response
//     return { ret: 'create table'};
//   })



//   fastify.post('/insert', async function (request, reply) {
    
//     // db connection
//     const connection = await fastify.mysql.getConnection()

//     // 유저 추가
//     const [rows, fields] = await connection.query(
//       `INSERT INTO test.test01(name, email) VALUES('Cheolwon', 'abcd@email.com')`
//     )
//     connection.release()
//     // return rows[0]


//     console.log('fin');
  
//     // Set the response status code
//     reply.code(201);
//     // Send the request body as the response
//     return { ret: 'insert db'};
//   })

//   fastify.get('/get', async function (request, reply) {

//     // db connection
//     const connection = await fastify.mysql.getConnection()

//     // 일단 추출
//     const [id, name, email] = await connection.query(
//       `SELECT * FROM test.test01`
//     )
//     connection.release()
  
//     // Set the response status code
//     reply.code(200);
//     // Send the request body as the response
//     return { port: 'funding_rw', ret: id};
//   })

//   fastify.post('/user', async function (request, reply) {

//     // db connection
//     const connection = await fastify.mysql.getConnection()

//     // table을 지워버림
//     await connection.query(
//       `DROP TABLE test.test01`
//     )
//     connection.release()
  
//     // Set the response status code
//     reply.code(201);
//     // Send the request body as the response
//     return { ret : 'delete table' };
//   })
}


