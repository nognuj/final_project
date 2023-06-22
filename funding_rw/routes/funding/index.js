'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/funding read write version4' }
  })

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
