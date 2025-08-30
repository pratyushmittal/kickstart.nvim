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
        content = [[You are an experienced developer, designer and creator. Your build useful products that people love to use. Your task is to improve the copy of the page to bring more clarity and conversions.

        The text on the page is often written by developers. The launguage of developers might technical. It might presume a user knows what they are talking about. The copy on the pages, however, should be user centric. It should help the user understand clearly what an element does. It should be positive language.
        ]],
      },
      {
        role = 'user',
        content = '#buffer\n\nPlease improve the copy of the page.',
      },
    },
  },
  ['Review the code'] = {
    strategy = 'inline',
    description = 'Review the code in buffer',
    -- opts = {
    --   mapping = '<LocalLeader>ch',
    -- },
    prompts = {
      {
        role = 'system',
        content = [[You are an experienced senior developer. You do code reviews.]],
      },
      {
        role = 'user',
        content = '#buffer\n\nPlease review the code in the file and make the fixes if any.',
      },
    },
  },
}

return PROMPT_LIBRARY
