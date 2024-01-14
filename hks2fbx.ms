rollout window "HKX2FBX" --菜单栏设置
(
    label Lb "批量导出Hkx动画为Fbx"

    edittext input_folder width:200
    button _input "指定导入路径"

    edittext skeleton_folder width:200
    button _skeleton "选择骨骼（导入动作必选）"

    edittext output_folder width:200
    button _output "指定导出路径（可选）"
    checkbox isRenameOutDir "设置输出文件夹名为文件的首编号" checked:false
    checkbox resetScene "每导入一遍文件都重置场景"

    button submit "确定"
    button clean "清理场景"

    local type = "*.hkx" --设置输入文件夹的指定格式

    -- 定义约束的文件类型
    local fileTypes = "HKX Files (*.hkx)|*.hkx|All Files (*.*)|*.*"

    on _input pressed do(
        input_path = getSavePath caption:"设置导入路径"
        
        if input_path != undefined do
        input_folder.text = input_path
    )
    on _output pressed do(
        output_path = getSavePath caption:"设置导出路径"

        if output_path != undefined do
        output_folder.text = output_path
    )
    on _skeleton pressed do(
        skeleton_file = getOpenFileName caption:"选择骨骼" types:fileTypes

        if skeleton_file != undefined do
        skeleton_folder.text = skeleton_file
    )

    on submit pressed do(
         --如果输入路径为空
        if(input_folder.text=="")then return "null"

        input_files = GetFilesOnType input_folder.text type
        --如果输出路径为空
        if(output_folder.text=="")then (
            if(isRenameOutDir.checked)then(
                print input_files
                fristName = getFilenameFile input_files[1] --获取首个文件名
                dirName = filterString fristName "_" --切割字符串
                output_folder.text = input_folder.text + @"\"+ dirName[1] + "_fbx" --拼接字符串
            )else(output_folder.text = input_folder.text+@"\output")
        )else(output_folder.text = input_folder.text+@"\output")

        makeDir output_folder.text --创建输出文件夹

        if(resetScene.checked) then resetMaxFile #noPrompt--检测是否清理场景

        if(skeleton_folder.text!="")then (
            Print ("导入骨骼"+skeleton_folder.text)
            importFile skeleton_folder.text #noPrompt
        )
        --遍历所有文件
        for file in input_files do(
            print ("inport: "+file)
            importFile file #noPrompt --导入
            
            fileName = getFilenameFile file
            outputFile = pathConfig.appendPath output_folder.text fileName
            print  ("export: "+outputFile)

            exportFile outputFile #noPrompt using:FBX --导出
        )
    )

    on clean pressed do(resetMaxFile #noPrompt)
)
createdialog window 230 250
fn GetFilesOnType folder type= --获取指定路径下所有指定后缀的文件
(
    currentFolderFiles = getFiles (folder + @"\" + type)
)
