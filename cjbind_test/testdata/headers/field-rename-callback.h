// cjbind-options: --field-rename-callback

struct RenameMe {
    int plain;
    int renamed_member;
    int bitfield_uGlyName : 1;
    int bitfieldWorse_name : 1;
};
