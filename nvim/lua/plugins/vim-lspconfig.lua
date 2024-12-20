return {
    "https://github.com/neovim/nvim-lspconfig",
    dependencies = {
        {
            "https://github.com/folke/neoconf.nvim",
            opts = {},
        },
    },
    config = function()
        local lspconfig = require("lspconfig")
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.resolveSupport = {
            properties = { "additionalTextEdits" },
        }

        require("mason-lspconfig").setup_handlers({
            -- Mason language servers with default setups
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,

            -- Mason language servers with custom setups
            basedpyright = function()
                lspconfig["basedpyright"].setup({
                    capabilities = capabilities,
                    settings = {
                        basedpyright = {
                            analysis = {
                                diagnosticSeverityOverrides = {
                                    reportImplicitStringConcatenation = false,
                                },
                            },
                        },
                    },
                })
            end,

            lua_ls = function()
                lspconfig["lua_ls"].setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            hint = {
                                enable = true,
                                ---@type "Auto" | "Enable" | "Disable"
                                arrayIndex = "Disable",
                                -- await = true,
                                -- ---@type "All" | "Literal" | "Disable"
                                -- paramName = "All",
                                -- paramType = true,
                                -- ---@type "All" | "SameLine" | "Disable"
                                -- semicolon = "SameLine",
                                -- setType = false,
                            },
                        },
                        diagnostics = { globals = { "vim" } }
                    },
                    on_init = function(client)
                        local ok, workspace_folder =
                        pcall(unpack, client.workspace_folders)
                        if not ok then
                            return
                        end
                        local path = workspace_folder.name
                        if
                            vim.uv.fs_stat(path .. "/.luarc.json")
                            or vim.uv.fs_stat(path .. "/.luarc.jsonc")
                            then
                                return
                            end

                            client.config.settings.Lua =
                            vim.tbl_deep_extend("force", client.config.settings.Lua, {
                                runtime = { version = "LuaJIT" },
                                workspace = {
                                    checkThirdParty = "Disable",
                                    library = {
                                        "${3rd}/luv/library",
                                        unpack(vim.api.nvim_get_runtime_file("", true)),
                                    },
                                },
                            })
                        end,
                        on_attach = function()
                            -- https://github.com/LuaLS/lua-language-server/issues/1809
                            vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
                        end,
                    })
                end,

                ts_ls = function()
                    lspconfig["ts_ls"].setup({
                        capabilities = capabilities,
                        root_dir = function(file)
                            return vim.fs.root(
                            file,
                            { "package.json", "tsconfig.json", "jsconfig.json" }
                            )
                        end,
                        single_file_support = false,
                        init_options = {
                            preferences = {
                                includeInlayEnumMemberValueHints = true,
                                -- includeInlayFunctionLikeReturnTypeHints = false,
                                -- includeInlayFunctionParameterTypeHints = false,
                                includeInlayParameterNameHints = "all",
                                -- includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                -- includeInlayPropertyDeclarationTypeHints = true,
                                -- includeInlayVariableTypeHints = false,
                                -- includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                            },
                            -- prevent omni completion from inserting extra period
                            completionDisableFilterText = true,
                        },
                        on_attach = function(client)
                            client.server_capabilities.documentFormattingProvider = false
                        end,
                    })
                end,
            })

        end,
    }
