'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: 'root funding read 일까요 배고픈 사자' }
  })
}
