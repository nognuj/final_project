'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: 'root funding rw 입니다 아니 없어' }
  })
}
