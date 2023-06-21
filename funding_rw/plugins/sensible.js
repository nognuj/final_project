'use strict'

const fp = require('fastify-plugin')

/**
 * This plugins adds some utilities to handle http errors
 *
 * @see https://github.com/fastify/fastify-sensible
 */
const {
  DB_USERNAME,
  DB_PASSWORD,
  DB_HOST,
  DB_TALBE
} = process.env

module.exports = fp(async function (fastify, opts) {
  fastify.register(require('@fastify/sensible'), {
    errorHandler: false
  })

  fastify.register(require('@fastify/mysql'), {
    promise: true,
    connectionString: `mysql://admin:12345678@database-2.cnd9cstsmizu.ap-northeast-2.rds.amazonaws.com/test`
  })
})
