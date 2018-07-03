app.directive 'accounts', ->
  return {
    restrict: 'E'
    templateUrl: '/templates/funds/accounts.html'
    scope: { localValue: '=accounts' }
    controller: ($scope, $state) ->
      ctrl = @
      @state = $state
      if window.location.hash == ""
        if gon.current_user.document_auth
          defaultCurrency = Account.first().currency
        else
          defaultCurrency = Account.first(2)[1].currency
        @state.transitionTo("deposits.currency", {currency: defaultCurrency})

      $scope.accounts = Account.all()

      # Might have a better way
      # #/deposits/eur
      if gon.current_user.document_auth
        defaultCurrency = Account.first().currency
      else
        defaultCurrency = Account.first(2)[1].currency
        if((window.location.hash.split('/')[1] == "withdraws") || (window.location.hash.split('/')[1] == "deposits" && window.location.hash.split('/')[2] == gon.fiat_currency))
          window.location.href = "id_document/edit"
      @selectedCurrency = window.location.hash.split('/')[2] || defaultCurrency
      @currentAction = window.location.hash.split('/')[1] || 'deposits'
      $scope.currency = @selectedCurrency

      @isSelected = (currency) ->
        @selectedCurrency == currency

      @isDeposit = ->
        @currentAction == 'deposits'

      @isWithdraw = ->
        @currentAction == 'withdraws'

      @deposit = (account) ->
        if(!gon.current_user.document_auth && gon.fiat_currency == account.currency)
          window.location.href = "id_document/edit"
        ctrl.state.transitionTo("deposits.currency", {currency: account.currency})
        ctrl.selectedCurrency = account.currency
        ctrl.currentAction = "deposits"

      @withdraw = (account) ->
        if(!gon.current_user.document_auth)
          window.location.href = "id_document/edit"
        ctrl.state.transitionTo("withdraws.currency", {currency: account.currency})
        ctrl.selectedCurrency = account.currency
        ctrl.currentAction = "withdraws"

      do @event = ->
        Account.bind "create update destroy", ->
          $scope.$apply()

    controllerAs: 'accountsCtrl'
  }

