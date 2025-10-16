-- https://github.com/kosayoda/nvim-lightbulb
-- lightbulbs for LSP code changes suggestions

return {
    {
        'kosayoda/nvim-lightbulb',
        opts = {
            autocmd = {
                enabled = true,
            },
            action_kinds = {
                "quickfix",
            },
            ignore = {
                actions_without_kind = true,
            },
            number = {
                enabled = true,
            },
            status_text = {
                enabled = true,
            },
        },
    },
}
