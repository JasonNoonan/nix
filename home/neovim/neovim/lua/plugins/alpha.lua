return {
	"goolord/alpha-nvim",
	opts = function(_, opts) -- override the options using lazy.nvim
		opts.section.header.val = { -- change the header section value
			"                          ¶¶",
			"              ¶¶        ¶¶nn¶¶  ¶¶",
			"            ¶¶nn¶¶        ¶¶nn¶¶nn¶¶",
			"          ¶¶nn¶¶¶¶¶¶¶¶¶¶¶¶nnnn¶¶nn¶¶                ¶¶",
			"         ¶¶nn¶¶nnnnnnnnnnnnn¶¶nnnn¶¶              ¶¶nn¶¶",
			"        ¶¶nnnnnnxxxxxxxxxxnnnnnnnn¶¶            ¶¶xxnn¶¶",
			"        ¶¶xxnn¶¶¶¶¶¶xxxxxxxxnnnnn¶¶           ¶¶¶¶xxnn¶¶¶¶",
			"      ¶¶¢¢nn¶¶¯¯¯¯¯¶¶¶xxxxxxnnaa¶¶          ¶¶xx¶¶xx¶¶xxnn¶¶",
			"      ¶¶¢¢¢n¶¶####¯¯¶¶xxnnnnnnaa¶¶          ¶¶xx¶¶xn¶¶xnnn¶¶¶¶",
			"      ¶¶¢¢¢¢¶¶ ###  ¶¶xnnnnnaa¶¶            ¶¶nnnnnn¶¶xxnn¶¶nn¶¶",
			"    ¶¶¢¢x¢¢¢¢¢¶¶¶¶¶¶nnnnnnaaa¶¶             ¶¶nnxxxxnnnn¶¶nnnn¶¶",
			"  ¶¶¢¢x¢¢¢¢¢¢¢¢¢¢¢¢§§nnnaaaa¶¶             ¶¶nnxxxxxxxnn¶¶nnnn¶¶",
			"¶¶¢¢xx¢¢¢¢¢¢¶¶¶¶§§§§nnnnnnaa¶¶            ¶¶nnxxxxxxnnnnnnaa¶¶",
			"¶¶¢¢x¢¢¢¶¶¶¶§§§§¶¶nnnnxxxxnnnn¶¶¶¶        ¶¶nnxxxxxxnnnnaa¶¶¶¶",
			"¶¶¢¢¢¢¶¶    ¶¶¶¶¶¶nnxxxxxxxxnnnnnn¶¶¶¶¶¶¶¶nnnnxx¶¶¶¶nnaaaaaaa¶¶",
			"  ¶¶¶¶¶      ¶¶nnnnxxxxxxxxnn¶¶nnnnnnnnnnnnn¶¶¶¶xxnn¶¶¶¶aaaa¶¶",
			"            ¶¶nn¶¶nnxxxxxxxx¶¶nnnnxxxxxxxxnnxxxxnn¶¶nnnna¶¶¶",
			"              ¶¶nnxxxxxxxx¶¶nnnnxxxxxxxxxxxxnn¶¶¶¶nnnnaa¶¶",
			"            ¶¶nnnnxxxxxxxx¶¶nnnnxxxxxxxxxxxxxxxxxxnnnn¶¶",
			"            ¶¶nnnnxxxxxxxxxx¶¶nnnnxxxxxxxxxxxxxxnnnn¶¶a¶¶",
			"           ¶¶nnnnnnnnnxxxxxx¶¶nnnnnnnnnnxxxxxxnnnnn¶¶a¶¶",
			"        ¶¶¶¶¶a¶¶aannnnnnnnnnnn¶¶aaaannnnnnnnnnnnaaaaaa¶¶",
			"      ¶¶xxnn¶¶¶¶aaaa¶¶aaaaaaaaaa¶¶aaaaaaaaaaaaaaaaaa¶¶¢¢¶¶",
			"        ¶¶xxn¶¶¶¶¶aaaa¶¶¶¶aaaaaaaa¶¶¶¶aaaaaaaaaa¶¶¶¶ƒƒƒƒ¢¢¶¶",
			"          ¶¶¢¢ƒƒ¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶    ¶¶¶¶¶¶¶¶¶¶  ¶¶¢¢¢¢¶¶",
			"            ¶¶¢¢ƒƒ¶¶¶¶¶¶ƒƒ¢¢ƒƒ¢¢¶¶                ¶¶ƒƒ¶¶¶¶¶¶¶¶",
			"             ¶¶ƒ¢¢¢¢ƒƒ¢¢ƒƒ¶¶¶¶¶¶                ¶¶ƒƒ¢¢¶¶¢¢nnxx¶¶",
			"              ¶¶ƒƒ¢¢ƒƒ¶¶¶¶                    ¶¶¶¶¢¢ƒƒ¢¢ƒƒ¶¶¶¶",
			"              ¶¶¢¢ƒƒ¶¶                  ¶¶¶¶¶¶¢¢ƒƒ¢¢¢¢¶¶¶¶",
			"              ¶¶nn¢¢¶¶                ¶¶xx¶¶xxnn¢¢¶¶¶¶",
			"              ¶¶xx¶¶                ¶¶xx¶¶xxnn¶¶¶¶",
			"                ¶¶                    ¶¶¶¶¶¶¶¶",
		}
		opts.section.header.opts.hl = "String"

		return opts
	end,
	-- enabled = false,
}
