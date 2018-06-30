namespace :ex do
  def make_order(params)
    {
      maker: '0x' + params[0]['address'],
      makerToken: '0x' + params[1]['address'],
      takerChain: params[2]['string'],
      takerToken: '0x' + params[3]['address'],
      makerAmount: params[4]['uint256'].to_i(16),
      takerAmount: params[5]['uint256'].to_i(16)
    }
  end

  task :orders => :environment do
    c = Rails.configuration.chains
    cita_cli = c['cita_cli_path']

    apollo = c['chains']['Apollo']
    barney = c['chains']['Barney']

    get_order = `#{cita_cli} ethabi encode function ./contracts/exchange_sol_Exchanger.abi getOrder --param 0`.gsub('"', '').strip

    puts "== Apollo"
    order_raw = JSON.parse(`#{cita_cli} rpc call --to #{apollo['ex_contract']} --data 0x#{get_order} --url #{apollo['rpc']}`)['result']
    order_params = JSON.parse(`#{cita_cli} ethabi decode params --data #{order_raw} --type address --type address --type string --type address --type uint --type uint`)

    puts JSON.pretty_generate(make_order(order_params))

    puts "== Barney"
    order_raw = JSON.parse(`#{cita_cli} rpc call --to #{barney['ex_contract']} --data 0x#{get_order} --url #{barney['rpc']}`)['result']
    order_params = JSON.parse(`#{cita_cli} ethabi decode params --data #{order_raw} --type address --type address --type string --type address --type uint --type uint`)

    puts JSON.pretty_generate(make_order(order_params))
  end

  task :alice => :environment do
    c = Rails.configuration.chains
    cita_cli = c['cita_cli_path']

    alice = c['users']['alice']
    apollo = c['chains']['Apollo']
    appo = apollo['token_contracts']['AAPO']['address'][2..-1]
    barney = c['chains']['Barney']
    abar = barney['token_contracts']['ABAR']['address'][2..-1]

    create_order = `#{cita_cli} ethabi encode function ./contracts/exchange_sol_Exchanger.abi createOrder --param #{appo} --param #{barney['rpc']} --param #{abar} --param 5 --param 10`.gsub('"', '').strip

    puts "== Alice offers APPO/Apollo, wants ABAR/Barney"
    puts `
      #{cita_cli} rpc sendRawTransaction --address #{apollo['ex_contract']} --code 0x#{create_order} --private-key #{alice['private_key']} --url #{apollo['rpc']}
    `
  end

  task :bob => :environment do
    c = Rails.configuration.chains
    cita_cli = c['cita_cli_path']

    bob = c['users']['bob']
    apollo = c['chains']['Apollo']
    appo = apollo['token_contracts']['AAPO']['address'][2..-1]
    barney = c['chains']['Barney']
    abar = barney['token_contracts']['ABAR']['address'][2..-1]

    create_order = `#{cita_cli} ethabi encode function ./contracts/exchange_sol_Exchanger.abi createOrder --param #{abar} --param #{apollo['rpc']} --param #{appo} --param 10 --param 5`.gsub('"', '').strip

    puts "== Bob offers ABAR/Barney, wants APPO/Apollo"
    puts `
      #{cita_cli} rpc sendRawTransaction --address #{barney['ex_contract']} --code 0x#{create_order} --private-key #{bob['private_key']} --url #{barney['rpc']}
    `
  end

  task :approve => :environment do
    c = Rails.configuration.chains
    cita_cli = c['cita_cli_path']

    bob = c['users']['bob']
    apollo = c['chains']['Apollo']
    appo = apollo['token_contracts']['AAPO']['address'][2..-1]
    barney = c['chains']['Barney']
    abar = barney['token_contracts']['ABAR']['address'][2..-1]
    deploy_key = c['users']['alice']['private_key']
    alice_addr = c['users']['alice']['address'][2..-1]
    bob_addr = c['users']['bob']['address'][2..-1]

    puts "== Transfer Alice APPO/Apollo to Bob"
    fill_alice_order = `#{cita_cli} ethabi encode function ./contracts/exchange_sol_Exchanger.abi fillOrder --param #{bob_addr}`.gsub('"', '').strip
    puts `
      #{cita_cli} rpc sendRawTransaction --address #{apollo['ex_contract']} --code 0x#{fill_alice_order} --private-key #{deploy_key} --url #{apollo['rpc']}
    `

    puts "== Transfer Bob ABAR/Barney to Alice"
    fill_bob_order = `#{cita_cli} ethabi encode function ./contracts/exchange_sol_Exchanger.abi fillOrder --param #{alice_addr}`.gsub('"', '').strip
    puts `
      #{cita_cli} rpc sendRawTransaction --address #{barney['ex_contract']} --code 0x#{fill_bob_order} --private-key #{deploy_key} --url #{barney['rpc']}
    `
  end
end
