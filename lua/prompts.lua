local PROMPT_LIBRARY = {
  ['Improve Copy'] = {
    strategy = 'inline',
    description = 'Improves the copy of the page',
    -- opts = {
    --   mapping = '<LocalLeader>ch',
    -- },
    prompts = {
      {
        role = 'system',
        content = [[You are an experienced developer, designer and creator. Your build useful products that people love to use. Your task is to improve the copy of the content to bring more clarity and improve conversions.]],
      },
      {
        role = 'user',
        content = '#buffer\n\nPlease improve the copy of the page.',
      },
    },
  },
}

return PROMPT_LIBRARY
