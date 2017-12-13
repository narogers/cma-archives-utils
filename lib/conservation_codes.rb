# Short codes for Conservation codes 
# 
# These codes are used by the Conservation department in file names to
# indicates various attributes of an image such as lighting, technique,
# stage, or location within the object. To use these simply require the
# library in any scripts that need to look up the values
module Conservation
  DIVISIONS = [
    "Asian Lab",
    "CIBL",
    "Objects Lab",
    "Paintings Lab",
    "Paper Lab",
    "Photographs",
    "Textile Lab"
  ]

  FIELDS = [
    :division, # Lab within the Conservation department,
    :conservation_type, # Category for image(s)
    :conservation_state, # Point at which image(s) are being captured
    :component, # Part of the obect being photographed
    :lighting, # Lighting methods used in image capture
    :sample_id, # Sequential identifier for samples
    :technique, # Photographic techiques used for capture
  ]

  SHORT_CODES = {
    CT: ["Conservation Treatment", :conservation_type],
    CL: ["Conservation Loan", :conservation_type],
    CR: ["Conservation Research", :conservation_type],
    CI: ["Conservation Installation", :conservation_type],
    CA: ["Conservation Analysis", :conservation_type],
    CE: ["Conservation Acquisition", :conservation_type],
    CX: ["Conservation Examination", :conservation_type],
    CER: ["Conservation External Research", :conservation_type],
    APP: ["Apparatus", :conservation_type],
    FR: ["Frame", :conservation_type],

    BT: ["Before Treatment", :conservation_state],
    DT: ["During Treatment", :conservation_state],
    AT: ["After Treatment", :conservation_state],
    SP: ["Sample", :conservation_state],
    BS: ["Before Sample", :conservation_state],
    AS: ["After Sample", :conservation_state],

    REC: ["Recto", :component],
    VER: ["Verso", :component],
    TOP: ["Top", :component],
    BOT: ["Bottom", :component],
    FNT: ["Front", :component],
    BCK: ["Back", :component],
    LFT: ["Left side of an object", :component],
    RGT: ["Right side of an object", :component],
    INT: ["Interior shot of an object", :component],
    EXT: ["Exterior shot of an object", :component],
    # DEG_xxx: "Degree",
    # DETxx: "Detail XX",
    # SECxx: "Section XX",
    DIA: ["Diagram", :component],
    HEAD: ["Head (book)", :component],
    SPINE: ["Spine (book)", :component],
    TAIL: ["Tail (book)", :component],
    FOREEDGE: ["Fore edge (book)", :component],
    # PGxx: "Page XX",

    NL: ["Normal light", :lighting],
    RL: ["Raking light", :lighting],
    TL: ["Transmitted light", :lighting],
    SL: ["Specular light", :lighting],
    OSL: ["Oblique Specular Light", :lighting],
    UV: ["Ultra Violet fluoresence", :lighting],
    IR: ["Infrared Reflectography", :lighting],
    XR: ["X-Ray", :lighting],
    RF: ["Reflected", :lighting],
    FCUV: ["False Color Ultraviolet", :lighting],
    FCIR: ["False Color Infrared", :lighting],

    # SPx: "Sample XX",
  
    MIC: ["Microscopy", :technique],
    XRF: ["X-ray Flourescence Spectroscopy", :technique],
    FTIR: ["Fourier Transform Infrared Spectroscopy", :technique],
    XRD: ["X-ray Diffraction", :technique],
    MICRO: ["Microscope Photos", :technique],
    SEM: ["Scanning Electron Microscope", :technique],
    SEMEDS: ["Scanning Electron Microscopy with Energy Dispersive Spectroscopy", :technique],
    GCMS: ["Gas Chromatography, Mass Spectroscopy", :technique],
    TLD: ["Thermo Luminescence Dating", :technique],
    HPLC: ["High Performance Liquid Chromotography", :technique],
    C14: ["Carbon 14 Dating", :technique]
  }
end
