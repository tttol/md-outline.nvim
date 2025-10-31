local M = {}
function M.hello() 
    print('hello md-outline!')
end

function M.main()
    print('main method is called.')
    M.hello()
end
 
return M
