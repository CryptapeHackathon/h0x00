namespace :erc20 do
  task :balance => :environment do
    c = Rails.configuration.chains
    cita_cli = c['cita_cli_path']
    alice_addr = c['users']['alice']['address'][2..-1]
    bob_addr = c['users']['bob']['address'][2..-1]

    apollo = c['chains']['Apollo']
    barney = c['chains']['Barney']
    appo = apollo['token_contracts']['AAPO']['address'][2..-1]
    abar = barney['token_contracts']['ABAR']['address'][2..-1]

    alice_balance_of = `#{cita_cli} ethabi encode function ./contracts/tokens_sol_ERC20Interface.abi balanceOf --param #{alice_addr}`.gsub('"', '').strip
    alice_aapo_balance = JSON.parse(`#{cita_cli} rpc call --to 0x#{appo} --data 0x#{alice_balance_of} --url #{apollo['rpc']}`)['result'].to_i(16)
    alice_abar_balance = JSON.parse(`#{cita_cli} rpc call --to 0x#{abar} --data 0x#{alice_balance_of} --url #{barney['rpc']}`)['result'].to_i(16)

    puts "Alice AAPO #{alice_aapo_balance}"
    puts "Alice ABAR #{alice_abar_balance}"

    bob_balance_of = `#{cita_cli} ethabi encode function ./contracts/tokens_sol_ERC20Interface.abi balanceOf --param #{bob_addr}`.gsub('"', '').strip
    bob_aapo_balance = JSON.parse(`#{cita_cli} rpc call --to 0x#{appo} --data 0x#{bob_balance_of} --url #{apollo['rpc']}`)['result'].to_i(16)
    bob_abar_balance = JSON.parse(`#{cita_cli} rpc call --to 0x#{abar} --data 0x#{bob_balance_of} --url #{barney['rpc']}`)['result'].to_i(16)

    puts "Bob AAPO #{bob_aapo_balance}"
    puts "Bob ABAR #{bob_abar_balance}"
  end

  task :charge => :environment do
    c = Rails.configuration.chains
    cita_cli = c['cita_cli_path']
    alice_addr = c['users']['alice']['address'][2..-1]
    bob_addr = c['users']['bob']['address'][2..-1]

    apollo = c['chains']['Apollo']
    barney = c['chains']['Barney']
    appo = apollo['token_contracts']['AAPO']['address'][2..-1]
    abar = barney['token_contracts']['ABAR']['address'][2..-1]

    deploy_key = c['users']['deploy']['private_key']

    transfer_to_alice = `#{cita_cli} ethabi encode function ./contracts/tokens_sol_ERC20Interface.abi transfer --param #{alice_addr} --param 1000`.gsub('"', '').strip
    puts "==== alice appo + 1000"
    puts `
      #{cita_cli} rpc sendRawTransaction --address 0x#{appo} --code 0x#{transfer_to_alice} --private-key #{deploy_key} --url #{apollo['rpc']}
    `
    puts "==== alice abar + 1000"
    puts `
      #{cita_cli} rpc sendRawTransaction --address 0x#{abar} --code 0x#{transfer_to_alice} --private-key #{deploy_key} --url #{barney['rpc']}
    `

    transfer_to_bob = `#{cita_cli} ethabi encode function ./contracts/tokens_sol_ERC20Interface.abi transfer --param #{bob_addr} --param 1000`.gsub('"', '').strip
    puts "==== bob appo + 1000"
    puts `
      #{cita_cli} rpc sendRawTransaction --address 0x#{appo} --code 0x#{transfer_to_bob} --private-key #{deploy_key} --url #{apollo['rpc']}
    `
    puts "==== bob abar + 1000"
    puts `
      #{cita_cli} rpc sendRawTransaction --address 0x#{abar} --code 0x#{transfer_to_bob} --private-key #{deploy_key} --url #{barney['rpc']}
    `
  end
end
