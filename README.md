# vimpv

WIP



## Config


```lua
-- ~/.config/nvim/lua/plugins.lua OR your config
-- use packer
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
use {
    'tk4e/vimpv.nvim',
    rtp = 'vimpv.nvim',
    -- ft = {'ass'},
    config = 'require [[Plug/vimpv]]'
}

end)


-- ~/.config/nvim/lua/Plug/vimpv.lua OR your config
require('vimpv').setup {
    tmp_dir = "/tmp/mpv/",
    tmp_file = "ass.lock",
    tmp_path = "/tmp/mpv/ass.lock",
    mode = "i",
    key = {
        pause = "<c-SPACE>",
        write = "<c-w>",
        set_time_start = "<c-s>",
        set_time_end = "<c-e>",
        seek_two = "<c-RIGHT>",
        seek_minus_two = "<c-LEFT>"
    }

}

vim.api.nvim_set_keymap('i', '<F1>', '<Cmd>:lua require"vimpv".menu()<CR>',
                        {noremap = true, silent = true})
```


```sh
# ~/.zshrc OR your config
vimpv() {
    vimpv_dir='/tmp'
    vimpv_file='mpv/ass.lock'
    vimpv_path="$vimpv_dir/$vimpv_file"

    if  [ $1 ]; then
        \mpv --input-ipc-server=$vimpv_path $1 &> "/dev/null" 2>&1 &
        sleep 0.5
        echo 'script-binding tk4e_time_format' | socat - $vimpv_path
        nvim $vimpv_dir/`echo $1 | cut -d . -f1`.ass
    fi


}
```



## How to use

```sh
pacman -S socat

vimpv test.mkv


# In neovim
# i<F1><c-space><c-space><c-s><c-e><c-w>
    # <F1>: open menu
    # <c-space>: pause
```
