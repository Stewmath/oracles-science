-- Lists for the oracles
lists = {}

ocl = dofile('lib\\ocl.lua')

lists.items = {
    'SHIELD',
    'PUNCH',
    'BOMBS',
    'CANE_OF_SOMARIA',
    'SWORD',
    'BOOMERANG',
    'ROD_OF_SEASONS',
    'MAGNET_GLOVES',
    'SWITCH_HOOK_HELPER',
    'SWITCH_HOOK',
    'SWITCH_HOOK_CHAIN',
    'BIGGORON_SWORD',
    'BOMBCHUS',
    'FLUTE',
    'SHOOTER',
    'NIL',
    'HARP',
    'NIL',
    'SLINGSHOT',
    'NIL',
    'SHOVEL',
    'BRACELET',
    'FEATHER',
    'NIL',
    'SEED_SATCHEL',
    'NIL',
    'NIL',
    'NIL',
    'MINECART_COLLISION',
    'FOOLS_ORE',
    'NIL',
    'EMBER_SEEDS',
    'SCENT_SEEDS',
    'PEGASUS_SEEDS',
    'GALE_SEEDS',
    'MYSTERY_SEEDS',
    'TUNE_OF_ECHOES',
    'TUNE_OF_CURRENTS',
    'TUNE_OF_AGES',
    'RUPEES',
    'HEART_REFILL',
    'HEART_CONTAINER',
    'HEART_PIECE',
    'RING_BOX',
    'RING',
    'FLIPPERS',
    'POTION',
    'SMALL_KEY',
    'BOSS_KEY',
    'COMPASS',
    'MAP',
    'GASHA_SEED',
    'NIL',
    'MAKU_SEED',
    'ORE_CHUNKS',
    'NIL',
    'NIL',
    'NIL',
    'NIL',
    'NIL',
    'NIL',
    'NIL',
    'NIL',
    'ESSENCE',
    'TRADEITEM',
}

if ocl.isAges() then
	lists.items[0x42] = 'GRAVEYARD_KEY' 
	lists.items[0x43] = 'CROWN_KEY'
	lists.items[0x44] = 'OLD_MERMAID_KEY'
	lists.items[0x45] = 'MERMAID_KEY'
	lists.items[0x46] = 'LIBRARY_KEY'
	lists.items[0x47] = '47'
	lists.items[0x48] = 'RICKY_GLOVES'
	lists.items[0x49] = 'BOMB_FLOWER'
	lists.items[0x4a] = 'MERMAID_SUIT'
	lists.items[0x4b] = 'SLATE'
	lists.items[0x4c] = 'TUNI_NUT'
	lists.items[0x4d] = 'SCENT_SEEDLING'
	lists.items[0x4e] = 'ZORA_SCALE'
	lists.items[0x4f] = 'TOKAY_EYEBALL'
	lists.items[0x50] = 'EMPTY_BOTTLE'
	lists.items[0x51] = 'FAIRY_POWDER'
	lists.items[0x52] = 'CHEVAL_ROPE'
	lists.items[0x53] = 'MEMBERS_CARD'
	lists.items[0x54] = 'ISLAND_CHART'
	lists.items[0x55] = 'BOOK_OF_SEALS'
	lists.items[0x56] = '56'
	lists.items[0x57] = '57'
	lists.items[0x58] = '58'
	lists.items[0x59] = 'GORON_LETTER'
	lists.items[0x5a] = 'LAVA_JUICE'
	lists.items[0x5b] = 'BROTHER_EMBLEM'
	lists.items[0x5c] = 'GORON_VASE'
	lists.items[0x5d] = 'GORONADE'
	lists.items[0x5e] = 'ROCK_BRISKET'
else
	lists.items[0x42] = 'GNARLED_KEY'
	lists.items[0x43] = 'FLOODGATE_KEY'
	lists.items[0x44] = 'DRAGON_KEY'
	lists.items[0x45] = 'STAR_ORE'
	lists.items[0x46] = 'RIBBON'
	lists.items[0x47] = 'SPRING_BANANA'
	lists.items[0x48] = 'RICKY_GLOVES'
	lists.items[0x49] = 'BOMB_FLOWER'
	lists.items[0x4a] = 'PIRATES_BELL'
	lists.items[0x4b] = 'TREASURE_MAP'
	lists.items[0x4c] = 'ROUND_JEWEL'
	lists.items[0x4d] = 'PYRAMID_JEWEL'
	lists.items[0x4e] = 'SQUARE_JEWEL'
	lists.items[0x4f] = 'X_SHAPED_JEWEL'
	lists.items[0x50] = 'RED_ORE'
	lists.items[0x51] = 'BLUE_ORE'
	lists.items[0x52] = 'HARD_ORE'
	lists.items[0x53] = 'MEMBERS_CARD'
	lists.items[0x54] = 'MASTERS_PLAQUE'
	lists.items[0x55] = '55'
	lists.items[0x56] = '56'
	lists.items[0x57] = '57'
	lists.items[0x58] = '58'
end

if ocl.isAges() then
    lists.globalFlags = {
        '10000_RUPEES_COLLECTED',
        'BEAT_GANON',
        '03',
        'GOT_SLAYERS_RING',
        'GOT_WEALTH_RING',
        'GOT_VICTORY_RING',
        '07',
        'OBTAINED_RING_BOX',
        'APPRAISED_HUNDREDTH_RING',
        'INTRO_DONE',
        '0b',
        '0c',
        '0d',
        'WON_FAIRY_HIDING_GAME',
        'D3_CRYSTALS',
        '10',
        'SAVED_NAYRU',
        'MAKU_TREE_SAVED',
        'SAW_TWINROVA_BEFORE_ENDGAME',
        'FINISHEDGAME',
        'GAVE_ROPE_TO_RAFTON',
        '16',
        '17',
        'BEGAN_POSSESSED_NAYRU_FIGHT',
        'BEAT_POSSESSED_NAYRU',
        'MOBLINS_KEEP_DESTROYED',
        'GOT_ISLAND_CHART',
        'GOT_BOMB_UPGRADE_FROM_FAIRY',
        'CAN_BUY_FLUTE',
        '1e',
        'PATCH_REPAIRED_EVERYTHING',
        'TALKED_TO_OCTOROK_FAIRY',
        'PREGAME_INTRO_DONE',
        'TALKED_TO_HEAD_CARPENTER',
        'GOT_FLUTE',
        'SAVED_COMPANION_FROM_FOREST',
        'SYMMETRY_BRIDGE_BUILT',
        'RAFTON_CHANGED_ROOMS',
        'KING_ZORA_CURED',
        'RING_SECRET_GENERATED',
        'TUNI_NUT_PLACED',
        '2a',
        'FOREST_UNSCRAMBLED',
        'SECRET_CHEST_WAITING',
        '2d',
        '2e',
        'SAVED_GORON_ELDER',
        'WATER_POLLUTION_FIXED',
        'GOT_PERMISSION_TO_ENTER_JABU',
        'RALPH_ENTERED_AMBIS_PALACE',
        'PRE_BLACK_TOWER_CUTSCENE_DONE',
        'PIRATES_GONE',
        'GOT_MAKU_SEED',
        'BOUGHT_FEATHER_FROM_TOKAY',
        'BOUGHT_BRACELET_FROM_TOKAY',
        'GOT_RING_FROM_ZELDA',
        'IMPA_MOVED_AFTER_ZELDA_KIDNAPPED',
        'FLAME_OF_DESPAIR_LIT',
        'RETURNED_DOG',
        'ZELDA_SAVED_FROM_VIRE',
        '3d',
        'MAKU_GIVES_ADVICE_FROM_PRESENT_MAP',
        'MAKU_GIVES_ADVICE_FROM_PAST_MAP',
        'RALPH_ENTERED_PORTAL',
        'ENTER_PAST_CUTSCENE_DONE',
        'COMPANION_LOST_IN_FOREST',
        'TALKED_TO_CHEVAL',
        '44',
        'RALPH_ENTERED_BLACK_TOWER',
        'GOT_SATCHEL_UPGRADE',
    }
else
    lists.globalFlags = {
        '10000_RUPEES_COLLECTED',
        'BEAT_GANON',
        '03',
        'GOT_SLAYERS_RING',
        'GOT_WEALTH_RING',
        'GOT_VICTORY_RING',
        '07',
        'OBTAINED_RING_BOX',
        'APPRAISED_HUNDREDTH_RING',
        'INTRO_DONE',
        'DATING_ROSA',
        '0c',
        '0d',
        '0e',
        '0f',
        '10',
        '11',
        '12',
        '13',
        '14',
        '15',
        'MOBLINS_KEEP_DESTROYED',
        'PIRATE_SHIP_DOCKED',
        '18',
        '19',
        '1a',
        '1b',
        '1c',
        '1d',
        '1e',
        '1f',
        '20',
        'PREGAME_INTRO_DONE',
        '22',
        '23',
        '24',
        '25',
        '26',
        '27',
        'FINISHEDGAME',
        '29',
        '3d',
        '2b',
        '2c',
        '2d',
        '2e',
        '2f',
        '30',
        'RING_SECRET_GENERATED',
        '32',
        '33',
        '34',
        '35',
        '36',
        '37',
        '38',
        '39',
        '3a',
        '3b',
        '3c',
        '3d',
        '3e',
        '3f',
        '40',
        '41',
        '42',
        '43',
        '44',
        '45',
        '46',
        '47',
        '48',
        '49',
        '4a',
        '4b',
        '4c',
        '4d',
        '4e',
        '4f'
    }
end
lists.globalFlags[0] = '1000_ENEMIES_KILLED' -- Indexes should never start at 1 :/


lists.rings = {}
lists.rings[0x00] = 'FRIENDSHIP_RING'
lists.rings[0x01] = 'POWER_RING_L1'
lists.rings[0x02] = 'POWER_RING_L2'
lists.rings[0x03] = 'POWER_RING_L3'
lists.rings[0x04] = 'ARMOR_RING_L1'
lists.rings[0x05] = 'ARMOR_RING_L2'
lists.rings[0x06] = 'ARMOR_RING_L3'
lists.rings[0x07] = 'RED_RING'
lists.rings[0x08] = 'BLUE_RING'
lists.rings[0x09] = 'GREEN_RING'
lists.rings[0x0a] = 'CURSED_RING'
lists.rings[0x0b] = 'EXPERTS_RING'
lists.rings[0x0c] = 'BLAST_RING'
lists.rings[0x0d] = 'RANG_RING_L1'
lists.rings[0x0e] = 'GBA_TIME_RING'
lists.rings[0x0f] = 'MAPLES_RING'
lists.rings[0x10] = 'STEADFAST_RING'
lists.rings[0x11] = 'PEGASUS_RING'
lists.rings[0x12] = 'TOSS_RING'
lists.rings[0x13] = 'HEART_RING_L1'
lists.rings[0x14] = 'HEART_RING_L2'
lists.rings[0x15] = 'SWIMMERS_RING'
lists.rings[0x16] = 'CHARGE_RING'
lists.rings[0x17] = 'LIGHT_RING_L1'
lists.rings[0x18] = 'LIGHT_RING_L2'
lists.rings[0x19] = 'BOMBERS_RING'
lists.rings[0x1a] = 'GREEN_LUCK_RING'
lists.rings[0x1b] = 'BLUE_LUCK_RING'
lists.rings[0x1c] = 'GOLD_LUCK_RING'
lists.rings[0x1d] = 'RED_LUCK_RING'
lists.rings[0x1e] = 'GREEN_HOLY_RING'
lists.rings[0x1f] = 'BLUE_HOLY_RING'
lists.rings[0x20] = 'RED_HOLY_RING'
lists.rings[0x21] = 'SNOWSHOE_RING'
lists.rings[0x22] = 'ROCS_RING'
lists.rings[0x23] = 'QUICKSAND_RING'
lists.rings[0x24] = 'RED_JOY_RING'
lists.rings[0x25] = 'BLUE_JOY_RING'
lists.rings[0x26] = 'GOLD_JOY_RING'
lists.rings[0x27] = 'GREEN_JOY_RING'
lists.rings[0x28] = 'DISCOVERY_RING'
lists.rings[0x29] = 'RANG_RING_L2'
lists.rings[0x2a] = 'OCTO_RING'
lists.rings[0x2b] = 'MOBLIN_RING'
lists.rings[0x2c] = 'LIKE_LIKE_RING'
lists.rings[0x2d] = 'SUBROSIAN_RING'
lists.rings[0x2e] = 'FIRST_GEN_RING'
lists.rings[0x2f] = 'SPIN_RING'
lists.rings[0x30] = 'BOMBPROOF_RING'
lists.rings[0x31] = 'ENERGY_RING'
lists.rings[0x32] = 'DBL_EDGED_RING'
lists.rings[0x33] = 'GBA_NATURE_RING'
lists.rings[0x34] = 'SLAYERS_RING'
lists.rings[0x35] = 'RUPEE_RING'
lists.rings[0x36] = 'VICTORY_RING'
lists.rings[0x37] = 'SIGN_RING'
lists.rings[0x38] = 'HUNDREDTH_RING'
lists.rings[0x39] = 'WHISP_RING'
lists.rings[0x3a] = 'GASHA_RING'
lists.rings[0x3b] = 'PEACE_RING'
lists.rings[0x3c] = 'ZORA_RING'
lists.rings[0x3d] = 'FIST_RING'
lists.rings[0x3e] = 'WHIMSICAL_RING'
lists.rings[0x3f] = 'PROTECTION_RING'
lists.rings[0x40] = 'DEV_RING (rando)'

return lists
