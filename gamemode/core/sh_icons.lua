//  Due to text drawing limitations, the icon font needs to be
//  split up into more than one font. Therefore, for the sake
//  simplicity, icons will be referenced by an ID, and this
//  will match that ID with the respective font and character
//  decimal value.
ICONS = {
    ["music"] = {Font = 1, Value = 33},
    ["search"] = {Font = 1, Value = 34},
    ["mail"] = {Font = 1, Value = 35},
    ["mail-alt"] = {Font = 1, Value = 36},
    ["heart"] = {Font = 1, Value = 37},
    ["heart-empty"] = {Font = 1, Value = 38},
    ["star"] = {Font = 1, Value = 39},
    ["star-empty"] = {Font = 1, Value = 40},
    ["user"] = {Font = 1, Value = 41},
    ["user-plus"] = {Font = 1, Value = 42},
    ["user-times"] = {Font = 1, Value = 43},
    ["users"] = {Font = 1, Value = 44},
    ["male"] = {Font = 1, Value = 45},
    ["female"] = {Font = 1, Value = 46},
    ["child"] = {Font = 1, Value = 47},
    ["user-secret"] = {Font = 1, Value = 48},
    ["picture"] = {Font = 1, Value = 49},
    ["camera"] = {Font = 1, Value = 50},
    ["th-large"] = {Font = 1, Value = 51},
    ["th"] = {Font = 1, Value = 52},
    ["th-list"] = {Font = 1, Value = 53},
    ["ok"] = {Font = 1, Value = 54},
    ["ok-circled"] = {Font = 1, Value = 55},
    ["cancel"] = {Font = 1, Value = 56},
    ["cancel-circled"] = {Font = 1, Value = 57},
    ["plus"] = {Font = 1, Value = 58},
    ["plus-circled"] = {Font = 1, Value = 59},
    ["minus"] = {Font = 1, Value = 60},
    ["minus-circle"] = {Font = 1, Value = 61},
    ["help"] = {Font = 1, Value = 62},
    ["info"] = {Font = 1, Value = 63},
    ["home"] = {Font = 1, Value = 64},
    ["link"] = {Font = 1, Value = 65},
    ["unlink"] = {Font = 1, Value = 66},
    ["link-ext"] = {Font = 1, Value = 67},
    ["lock"] = {Font = 1, Value = 68},
    ["lock-open-alt"] = {Font = 1, Value = 69},
    ["pin"] = {Font = 1, Value = 70},
    ["eye"] = {Font = 1, Value = 71},
    ["eye-off"] = {Font = 1, Value = 72},
    ["tag"] = {Font = 1, Value = 73},
    ["bookmark"] = {Font = 1, Value = 74},
    ["bookmark-empty"] = {Font = 1, Value = 75},
    ["thumbs-up"] = {Font = 1, Value = 76},
    ["thumbs-down"] = {Font = 1, Value = 77},
    ["thumbs-up-alt"] = {Font = 1, Value = 78},
    ["thumbs-down-alt"] = {Font = 1, Value = 79},
    ["download"] = {Font = 1, Value = 80},
    ["upload"] = {Font = 1, Value = 81},
    ["reply"] = {Font = 1, Value = 82},
    ["reply-all"] = {Font = 1, Value = 83},
    ["forward"] = {Font = 1, Value = 84},
    ["quote-left"] = {Font = 1, Value = 85},
    ["code"] = {Font = 1, Value = 86},
    ["pencil"] = {Font = 1, Value = 87},
    ["edit"] = {Font = 1, Value = 88},
    ["comment"] = {Font = 1, Value = 89},
    ["chat"] = {Font = 1, Value = 90},
    ["comment-empty"] = {Font = 1, Value = 91},
    ["chat-empty"] = {Font = 1, Value = 92},
    ["bell"] = {Font = 1, Value = 93},
    ["bell-alt"] = {Font = 1, Value = 94},
    ["bell-off"] = {Font = 1, Value = 95},
    ["bell-off-empty"] = {Font = 1, Value = 96},
    ["attention-alt"] = {Font = 1, Value = 97},
    ["attention"] = {Font = 1, Value = 98},
    ["location"] = {Font = 1, Value = 99},
    ["direction"] = {Font = 1, Value = 100},
    ["trash"] = {Font = 1, Value = 101},
    ["trash-empty"] = {Font = 1, Value = 102},
    ["doc"] = {Font = 1, Value = 103},
    ["docs"] = {Font = 1, Value = 104},
    ["folder"] = {Font = 1, Value = 105},
    ["folder-open"] = {Font = 1, Value = 106},
    ["folder-empty"] = {Font = 1, Value = 107},
    ["folder-open-empty"] = {Font = 1, Value = 108},
    ["phone"] = {Font = 1, Value = 109},
    ["menu"] = {Font = 1, Value = 110},
    ["cog"] = {Font = 1, Value = 111},
    ["cog-alt"] = {Font = 1, Value = 112},
    ["wrench"] = {Font = 1, Value = 113},
    ["sliders"] = {Font = 1, Value = 114},
    ["basket"] = {Font = 1, Value = 115},
    ["calendar"] = {Font = 1, Value = 116},
    ["login"] = {Font = 1, Value = 117},
    ["logout"] = {Font = 1, Value = 118},
    ["mic"] = {Font = 1, Value = 119},
    ["mute"] = {Font = 1, Value = 120},
    ["volume-off"] = {Font = 1, Value = 121},
    ["volume-down"] = {Font = 1, Value = 122},
    ["volume-up"] = {Font = 1, Value = 123},
    ["headphones"] = {Font = 1, Value = 124},
    ["clock"] = {Font = 1, Value = 125},
    ["block"] = {Font = 1, Value = 126},

    ["zoom-in"] = {Font = 2, Value = 33},
    ["zoom-out"] = {Font = 2, Value = 34},
    ["down-dir"] = {Font = 2, Value = 35},
    ["up-dir"] = {Font = 2, Value = 36},
    ["left-dir"] = {Font = 2, Value = 37},
    ["right-dir"] = {Font = 2, Value = 38},
    ["down-open"] = {Font = 2, Value = 39},
    ["left-open"] = {Font = 2, Value = 40},
    ["right-open"] = {Font = 2, Value = 41},
    ["up-open"] = {Font = 2, Value = 42},
    ["angle-double-left"] = {Font = 2, Value = 43},
    ["angle-double-right"] = {Font = 2, Value = 44},
    ["angle-double-up"] = {Font = 2, Value = 45},
    ["angle-double-down"] = {Font = 2, Value = 46},
    ["arrows-cw"] = {Font = 2, Value = 47},
    ["play"] = {Font = 2, Value = 48},
    ["stop"] = {Font = 2, Value = 49},
    ["pause"] = {Font = 2, Value = 50},
    ["target"] = {Font = 2, Value = 51},
    ["signal"] = {Font = 2, Value = 52},
    ["wifi"] = {Font = 2, Value = 53},
    ["award"] = {Font = 2, Value = 54},
    ["laptop"] = {Font = 2, Value = 55},
    ["tablet"] = {Font = 2, Value = 56},
    ["inbox"] = {Font = 2, Value = 57},
    ["globe"] = {Font = 2, Value = 58},
    ["sun"] = {Font = 2, Value = 59},
    ["cloud"] = {Font = 2, Value = 60},
    ["flash"] = {Font = 2, Value = 61},
    ["moon"] = {Font = 2, Value = 62},
    ["text-height"] = {Font = 2, Value = 63},
    ["align-left"] = {Font = 2, Value = 64},
    ["align-justify"] = {Font = 2, Value = 65},
    ["list"] = {Font = 2, Value = 66},
    ["list-bullet"] = {Font = 2, Value = 67},
    ["scissors"] = {Font = 2, Value = 68},
    ["paste"] = {Font = 2, Value = 69},
    ["ellipsis"] = {Font = 2, Value = 70},
    ["ellipsis-vert"] = {Font = 2, Value = 71},
    ["off"] = {Font = 2, Value = 72},
    ["adjust"] = {Font = 2, Value = 73},
    ["circle"] = {Font = 2, Value = 74},
    ["circle-empty"] = {Font = 2, Value = 75},
    ["chart-bar"] = {Font = 2, Value = 76},
    ["floppy"] = {Font = 2, Value = 77},
    ["megaphone"] = {Font = 2, Value = 78},
    ["hdd"] = {Font = 2, Value = 79},
    ["tasks"] = {Font = 2, Value = 80},
    ["dollar"] = {Font = 2, Value = 81},
    ["rouble"] = {Font = 2, Value = 82},
    ["heartbeat"] = {Font = 2, Value = 83},
    ["cube"] = {Font = 2, Value = 84},
    ["cubes"] = {Font = 2, Value = 85},
    ["database"] = {Font = 2, Value = 86},
    ["server"] = {Font = 2, Value = 87},
    ["lifebuoy"] = {Font = 2, Value = 88},
    ["venus"] = {Font = 2, Value = 89},
    ["mars"] = {Font = 2, Value = 90},
    ["github"] = {Font = 2, Value = 91},
    ["paypal"] = {Font = 2, Value = 92},
    ["steam"] = {Font = 2, Value = 93},
    ["steam-squared"] = {Font = 2, Value = 94},
    ["windows"] = {Font = 2, Value = 95},
    ["apple"] = {Font = 2, Value = 96},
    ["linux"] = {Font = 2, Value = 97},
    ["battery-4"] = {Font = 2, Value = 98},
    ["battery-3"] = {Font = 2, Value = 99},
    ["battery-2"] = {Font = 2, Value = 100},
    ["battery-1"] = {Font = 2, Value = 101},
    ["battery-0"] = {Font = 2, Value = 102},
    ["hourglass-1"] = {Font = 2, Value = 103},
    ["hourglass-2"] = {Font = 2, Value = 104},
    ["hourglass-3"] = {Font = 2, Value = 105},
    ["map-o"] = {Font = 2, Value = 106},
    ["map"] = {Font = 2, Value = 107},
    ["spin1"] = {Font = 2, Value = 108},
    ["spin2"] = {Font = 2, Value = 109},
    ["spin3"] = {Font = 2, Value = 110},
    ["spin4"] = {Font = 2, Value = 111},
    ["spin5"] = {Font = 2, Value = 112},
    ["spin6"] = {Font = 2, Value = 113}
};
