<template>
  <div id="app">
    <md-app>
      <md-app-toolbar>
        <h1 class="md-title">
          Note Chain
        </h1>
      </md-app-toolbar>

      <md-app-content>
        <md-card v-for="note in noteTable" :key="note.key">
          <md-card-content>
            <h2 class="md-title">
              {{ note.user }}
            </h2>
            <span class="md-caption">
              {{ new Date(note.timestamp*1000).toString() }}
            </span>
            <pre class="md-body-1" v-text="note.note" />
          </md-card-content>
        </md-card>

        <md-content>
          <form @submit.prevent="handleFormEvent" class="md-layout">
            <md-field>
              <label>Account</label>
              <md-input v-model="formData.account" required></md-input>
            </md-field>

            <md-field>
              <label>Private Key</label>
              <md-input v-model="formData.privateKey" required></md-input>
            </md-field>

            <md-field>
              <label>Note (Optional)</label>
              <md-textarea v-model="formData.note" md-autogrow></md-textarea>
            </md-field>

            <md-button
              class="md-dense md-raised md-primary"
              type="submit"
              fullwidth>
              Add / Update note
            </md-button>
          </form>
        </md-content>

        <pre class="accounts">Below is a list of pre-created accounts information for add/update note:<br/><br/>{{ JSON.stringify(accounts, null, 2) }}</pre>
      </md-app-content>
    </md-app>
  </div>
</template>

<style scoped>
.md-card {
  margin-top: 10px;
}
.accounts {
  background: #ccc;
  padding: 10px;
  margin-bottom: 0;
}
.md-button {
  width: 100%;
  margin: 0;
}
</style>

<script>
import { Api, JsonRpc, JsSignatureProvider } from 'eosjs' // https://github.com/EOSIO/eosjs
// eosio endpoint
const endpoint = 'http://localhost:8888'

export default {
  name: 'app',
  data () {
    return {
      noteTable: [],
      formData: {
        account: 'useraaaaaaaa',
        privateKey: '5K7mtrinTFrVTduSxizUc5hjXJEtTjVTsqSHeBHes1Viep86FP5',
        note: ''
      },
      // NEVER store private keys in any source code in your real life development
      // This is for demo purposes only!
      accounts: [
        { 'name': 'useraaaaaaaa', 'privateKey': '5K7mtrinTFrVTduSxizUc5hjXJEtTjVTsqSHeBHes1Viep86FP5', 'publicKey': 'EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b' },
        { 'name': 'useraaaaaaab', 'privateKey': '5KLqT1UFxVnKRWkjvhFur4sECrPhciuUqsYRihc1p9rxhXQMZBg', 'publicKey': 'EOS78RuuHNgtmDv9jwAzhxZ9LmC6F295snyQ9eUDQ5YtVHJ1udE6p' },
        { 'name': 'useraaaaaaac', 'privateKey': '5K2jun7wohStgiCDSDYjk3eteRH1KaxUQsZTEmTGPH4GS9vVFb7', 'publicKey': 'EOS5yd9aufDv7MqMquGcQdD6Bfmv6umqSuh9ru3kheDBqbi6vtJ58' },
        { 'name': 'useraaaaaaad', 'privateKey': '5KNm1BgaopP9n5NqJDo9rbr49zJFWJTMJheLoLM5b7gjdhqAwCx', 'publicKey': 'EOS8LoJJUU3dhiFyJ5HmsMiAuNLGc6HMkxF4Etx6pxLRG7FU89x6X' },
        { 'name': 'useraaaaaaae', 'privateKey': '5KE2UNPCZX5QepKcLpLXVCLdAw7dBfJFJnuCHhXUf61hPRMtUZg', 'publicKey': 'EOS7XPiPuL3jbgpfS3FFmjtXK62Th9n2WZdvJb6XLygAghfx1W7Nb' },
        { 'name': 'useraaaaaaaf', 'privateKey': '5KaqYiQzKsXXXxVvrG8Q3ECZdQAj2hNcvCgGEubRvvq7CU3LySK', 'publicKey': 'EOS5btzHW33f9zbhkwjJTYsoyRzXUNstx1Da9X2nTzk8BQztxoP3H' },
        { 'name': 'useraaaaaaag', 'privateKey': '5KFyaxQW8L6uXFB6wSgC44EsAbzC7ideyhhQ68tiYfdKQp69xKo', 'publicKey': 'EOS8Du668rSVDE3KkmhwKkmAyxdBd73B51FKE7SjkKe5YERBULMrw' }
      ]
    }
  },
  methods: {
    handleFormEvent () {
      // collect form data
      let account = this.formData.account
      let privateKey = this.formData.privateKey
      let note = this.formData.note

      // prepare variables for the switch below to send transactions
      let actionName = ''
      let actionData = {}

      // define actionName and action according to event type
      switch (event.type) {
        case 'submit':
          actionName = 'update'
          actionData = {
            user: account,
            note: note
          }
          break
        default:
          return
      }

      // eosjs function call: connect to the blockchain
      const rpc = new JsonRpc(endpoint)
      const signatureProvider = new JsSignatureProvider([privateKey])
      const api = new Api({ rpc, signatureProvider, textDecoder: new TextDecoder(), textEncoder: new TextEncoder() })
      api.transact({
        actions: [{
          account: 'notechainacc',
          name: actionName,
          authorization: [{
            actor: account,
            permission: 'active'
          }],
          data: actionData
        }]
      }, {
        blocksBehind: 3,
        expireSeconds: 30
      }).then(result => {
        console.log(result)
        this.getTable()
      })
    },
    getTable () {
      const rpc = new JsonRpc(endpoint)
      rpc.get_table_rows({
        'json': true,
        'code': 'notechainacc', // contract who owns the table
        'scope': 'notechainacc', // scope of the table
        'table': 'notestruct', // name of the table as specified by the contract abi
        'limit': 100
      }).then(result => {
        this.noteTable = result.rows
      })
    }
  },
  mounted () {
    this.getTable()
  }
}
</script>
