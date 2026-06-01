#import "../../templates/illustrated-poem-page.typ": illustrated-poem-page
#import "../../templates/auto-pinyin/lib.typ": to-pinyin

#let txt(value) = text(value)
#let pinyin-annotations(lines, override) = {
  let annotations = ()
  for (line-index, line) in lines.enumerate() {
    let chars = line.clusters()
    let pinyins = to-pinyin(line, style: "tone", override: override)
    for (cell-index, cell) in chars.enumerate() {
      let py = pinyins.at(cell-index)
      if py != cell {
        annotations.push((line: line-index, cell: cell-index, text: py))
      }
    }
  }
  annotations
}

#let title-pinyin(title, override) = {
  to-pinyin(title, style: "tone", override: override).zip(title.clusters()).map(pair => if pair.first() == pair.last() { none } else { pair.first() })
}

#let render-poem(title, poem-lines, context-note, commentary, asset, override) = {
  let render-image = (w, h, fit) => image("../../" + asset, width: w, height: h, fit: fit)
  illustrated-poem-page(
    title,
    poem-lines.map(line => line.clusters()),
    context-note,
    commentary,
    render-image,
    pinyin: pinyin-annotations(poem-lines, override),
    title-cells: title.clusters(),
    title-pinyin: title-pinyin(title, override),
  )
}

#set document(title: "冶文斋诗选", author: "宋皿")
#set page(width: 210mm, height: 297mm, margin: (x: 24mm, y: 24mm), fill: rgb("#f8f1e6"))
#set text(lang: "zh", region: "cn", font: "STFangsong", size: 11pt, fill: rgb("#2f231f"))
#set heading(numbering: "一、")

#align(center + horizon)[#text(font: "Zhuque Fangsong (technical preview)", size: 30pt)[冶文斋诗选]\ #v(18pt)#text(size: 13pt)[Typst 插画本]]
#pagebreak()
= 序
#block(above: 0pt, below: 9pt)[#txt("（待补）")]
#pagebreak()
= 凡例
#block(above: 0pt, below: 9pt)[#txt("本书按题材分章，章节顺序与诗作顺序承袭原《冶文斋诗选》。")]
#block(above: 0pt, below: 9pt)[#txt("每首诗页包含题名、正文、创作背景、拼音标注与插画。只有对应赏析标记为 `human-revised` 或 `reference-quality` 时，才收入并排入诗页。")]
#block(above: 0pt, below: 9pt)[#txt("拼音标注以自动查音为基础，并叠加诗作 frontmatter 中的人工修正；人工修正优先。")]
#block(above: 0pt, below: 9pt)[#txt("创作背景来自诗作 frontmatter 的 `context` 字段。")]
#block(above: 0pt, below: 9pt)[#txt("收入的赏析为 LLM 辅助起草、作者审订后的文本。方法与限制见附录《LLM 辅助赏析写作说明》。")]
#block(above: 0pt, below: 9pt)[#txt("插画是依据诗作与赏析生成的文学化阐释，不作为纪实证据或精确复原。")]
#block(above: 0pt, below: 9pt)[#txt("部分诗作缺少可确认写作时间，年谱只按年份与季节展示，未定年诗作不列入年谱。")]
#pagebreak()
= 目录
#outline()
#pagebreak()
= 职业生涯
#text(size: 12pt)[本章收录 23 首。]
#pagebreak()
#{
  let title = "心旗"
  let poem_lines = ("百挫得来倍珍惜，", "阻滞关头意须决。", "于无措中求巧解，", "为矢寻的践其约。")
  let context_note = "项目攻坚所作。"
  let commentary = ()
  let asset = "assets/poems/心旗/illustration.png"
  let override = ("的": "dí")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "屡战"
  let poem_lines = ("筹营后方不甘寂，", "杂中炼精视非途。", "弃者岂能垮我辈，", "再塑箫规重上路。")
  let context_note = "团队成员提出离职所作。"
  let commentary = ()
  let asset = "assets/poems/屡战/illustration.png"
  let override = ("重": "chóng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "断舍"
  let poem_lines = ("远景渐朗继有人，", "重燃狼性断舍离。", "案头宗卷恍隔世，", "再铺新纸染心血。")
  let context_note = "组织上安排转岗所作。"
  let commentary = ()
  let asset = "assets/poems/断舍/illustration.png"
  let override = ("重": "chóng", "卷": "juàn")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "统帅"
  let poem_lines = ("倾采思量行果决，", "步子错落渐有致。", "登高远望酿山河，", "绳心养性融诸识。")
  let context_note = "有感于团队中长期规划对leader修养的要求而作。"
  let commentary = ()
  let asset = "assets/poems/统帅/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "雨澜"
  let poem_lines = ("羡欲摇曳川蚀岩，", "志安心谷雨汇洼。", "念顽意涩以真灼，", "锤炼研磨候缘期。")
  let context_note = "羡慕他人际遇所作。"
  let commentary = ()
  let asset = "assets/poems/雨澜/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "整装"
  let poem_lines = ("卸壳拆戏剖心柳，", "意寒行豫沐暖颜。", "接骨缝漏重举伞，", "铸诚为翼越渊堑。")
  let context_note = "重大打击后通过谈心重整旗鼓所作。"
  let commentary = ()
  let asset = "assets/poems/整装/illustration.png"
  let override = ("重": "chóng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "战时"
  let poem_lines = ("弛弓引势砺筋骨，", "逐猎令出箭夺的。", "就材起灶拼白刃，", "莫待兵成恨狼藉。")
  let context_note = "有感于中长期建设赶不上当下应对挑战所需而作。"
  let commentary = ()
  let asset = "assets/poems/战时/illustration.png"
  let override = ("的": "dí")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "泳夜"
  let poem_lines = ("一章功成万牍耽，", "载愿千钧辙痕浅。", "身投静波辉影间，", "念出屏囚另开天。")
  let context_note = "是夜，与妻女夜泳嬉戏，少顷，妻女还家，独自泳于夜色之中。近日案牍之上，多有事倍功半、愿实背离、罔顾错憾、悬空未决之事，未达使命之感挥之不去，心念中轴转无隙。累时，往往流连美剧，或沉浸手游，不过仍是屏幕的囚徒，以一时之娱回复能量，并未真正休憩。直至回归泳池，目之所及皆是淡蓝辉影，千头万绪，方归于静谧，是以凝成此诗。"
  let commentary = ()
  let asset = "assets/poems/泳夜/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "拭剑"
  let poem_lines = ("缩岛沉舟谐何妥，", "应付终托痂涩喜。", "誓绝因庸疑误己，", "择伙践志斩荆棘。")
  let context_note = "前两句背后的故事是在与人相处、职业发展等方面受挫后迎来转机。后两句是反思过程中的自我怀疑以及作为上的犹豫。"
  let commentary = ()
  let asset = "assets/poems/拭剑/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "型势"
  let poem_lines = ("宝剑初锋无当者，", "细琢日用千面同。", "鞘藏温养愈敛涵，", "逢境但出破长空。")
  let context_note = "在工作上挑战不够的阶段所作。"
  let commentary = ()
  let asset = "assets/poems/型势/illustration.png"
  let override = ("长": "cháng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "伙伴"
  let poem_lines = ("成败中道凝风云，", "是非成空伙相觑。", "执事当惜眼前伴，", "共历契心战相许。")
  let context_note = "项目调整后有感于要珍惜项目中的伙伴而作。"
  let commentary = ()
  let asset = "assets/poems/伙伴/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "投融"
  let poem_lines = ("盘综境陌张景怀，", "斗转晨曦筹措形。", "临渊望岸纵身跃，", "漠荒岭峻向北星。")
  let context_note = "来到新项目，全力应对全新挑战所作。"
  let commentary = ()
  let asset = "assets/poems/投融/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "直前"
  let poem_lines = ("一叶入秋既别枝，", "凭风起舞借扬时。", "狡兔恋窟伤末途，", "勇往兼济未可知。")
  let context_note = "下定决心承担角色出战所作。"
  let commentary = ()
  let asset = "assets/poems/直前/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "信使"
  let poem_lines = ("迟翔青鸟赴淤途，", "知候犹诺愿履辛。", "纷扰投射居中炼，", "蛰坐辗转舒长心。")
  let context_note = "承担角色出战后陷入持久战所作。"
  let commentary = ()
  let asset = "assets/poems/信使/illustration.png"
  let override = ("长": "cháng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "失学"
  let poem_lines = ("青葱恋文哲，", "史传鄙尘辉。", "当得执绥刻，", "方知烛炬微。")
  let context_note = "担当重要而复杂的角色，有感于所读历史与传记不够、自身底蕴不足而作。"
  let commentary = ()
  let asset = "assets/poems/失学/illustration.png"
  let override = ("传": "zhuàn")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "将息"
  let poem_lines = ("施张百挫知危困，", "润物开锋竭所及。", "且听雀声荐鸩媒，", "收帆稳舵抚蓑笠。")
  let context_note = "急流勇退所作。"
  let commentary = ()
  let asset = "assets/poems/将息/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "闯潭"
  let poem_lines = ("起航远望轻风雨，", "险鲨恶浪守机舱。", "展振蝶翅牵调顺，", "云泥扑朔引天光。")
  let context_note = "项目遇到未预料的挑战，站好自己这班岗，并有限度地尝试影响全局走向。"
  let commentary = ()
  let asset = "assets/poems/闯潭/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "前行"
  let poem_lines = ("忠人以诚莫依附，", "江湖闯荡不回头。", "并肩新遇轻装战，", "交游故旧遍神州。")
  let context_note = "告别忠爱的领导投入新的人际变局和战场气象而作。"
  let commentary = ()
  let asset = "assets/poems/前行/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "莫测"
  let poem_lines = ("敌彀深陷背来芒，", "以身树桃细思量。", "浅滩瘠田何相卷，", "潮间径筑承钧梁。")
  let context_note = "在凶险局势中管理层更替犹豫疑虑后细思定心深耕而作。"
  let commentary = ()
  let asset = "assets/poems/莫测/illustration.png"
  let override = ("量": "liáng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "赴蹈"
  let poem_lines = ("逐流布子岂轻弃，", "舍性收官莫负托。", "殷情亭歇盼君归，", "挥别善颜履险薄。")
  let context_note = "决意不退却回避，出差直面心魔而作。"
  let commentary = ()
  let asset = "assets/poems/赴蹈/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "难抉"
  let poem_lines = ("吞吐万事景无穷，", "沉浮此身那堪侵。", "一生尽负时光债，", "行藏巧拙霎时心。")
  let context_note = "做关键抉择时，回顾既往，斟酌未来，从辛弃疾《鹧鸪天·不寐》、《重午日戏书》中采字所作。亦作为一次徒步的配诗。"
  let commentary = ()
  let asset = "assets/poems/难抉/illustration.png"
  let override = ("拙": "zhuó")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "返初"
  let poem_lines = ("林错风穿逡巡雁，", "木桥野径过无痕。", "碧波石色生机驳，", "半阙落潮洗心仁。")
  let context_note = "徒步见景，有感于一切回到原点而作。"
  let commentary = ("《返初》一诗，虽未直言主题，却于字里行间悄然渗透出回归本真、探寻内心质朴的深邃情愫，引领读者踏入一个满溢自然哲思与幽微静谧的诗意天地。", "开篇「林错风穿逡巡雁」，诗人以细腻笔触勾勒出一幅动静交融的灵动画面。「林错」描绘出树林错落有致又不失繁杂的独特形态，恰似大自然随性挥洒的笔墨，构建出别具一格的空间感。「风穿」赋予画面鲜活动态，无形之风穿梭于林间，树叶沙沙作响，宛如自然的信使，传递着隐秘的信息。而「逡巡雁」则为画面增添点睛之笔，大雁在空中徘徊往复，它们或因季节迁徙，或在寻觅栖息之所，这种徘徊不定不仅为画面增添空灵与迷茫，更暗示着诗人内心深处的寻觅与探索。", "「木桥野径过无痕」，进一步将读者引入清幽静谧之境。木桥横跨，野径蜿蜒，它们是连接自然与人类活动的微妙纽带。「过无痕」三字，营造出超脱尘世纷扰的独特意境。行人走过木桥与野径，却未留下显著痕迹，恰似人生于世，匆匆而过，应超脱世俗羁绊，追求一种纯净自然的状态，犹如禅宗所云「雁过长空，影沉寒水，雁无遗踪之意，水无留影之心」，尽显超脱物外的洒脱。", "颔联「碧波石色生机驳」，诗人将目光凝于水与石。碧波荡漾，尽显生命的灵动与活力，石头之色则为画面添几分沉稳厚重。「生机驳」描绘出二者交织间，呈现出斑驳陆离的蓬勃生机，仿佛大自然的生命于这小小一隅肆意绽放，展现生命的多元与丰富，隐喻着返初并非简单回归，而是在纷繁生命体验中探寻本真。", "尾句「半阙落潮洗心仁」，为全诗灵魂。「半阙」或暗示人生的不完整、世事的残缺，「落潮」作为自然律动，潮水退去，喧嚣浮躁随之消散。若将「心仁」理解为把心比作果仁，果仁深藏于果实之中，象征内心最纯净、本质的部分。借落潮之力洗涤心灵，寓意褪去心灵层层外壳，显露如同果仁般质朴纯粹的本心。此句传达出诗人历经世事沧桑后，渴望回归内心最真实柔软之处，珍视内心未经雕琢的纯净善良。", "整首诗语言凝练，意象丰富，借自然之景营造空灵静谧氛围，在自然与心灵交融间，深刻传达「返初」主题，引导读者于喧嚣尘世探寻内心宁静本真。")
  let asset = "assets/poems/返初/illustration.png"
  let override = ("阙": "què")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "流迁"
  let poem_lines = ("沉浮兜转尽由人，", "倏忽摘取恣揉捏。", "心相泡影习成常，", "始知交变叙事迭。")
  let context_note = "交接牵缠所作。"
  let commentary = ("此诗意象简练而富张力，于物象流转中暗藏人生况味，具古典诗歌含蓄之致。四句诗如四幅水墨小品，初观似写寻常物事，细品却见烟霞深处，于留白处藏尽人间变相，于简淡中寓含哲思深微，展现出对生命本质与认知规律的深刻叩问。", "首句「沉浮兜转尽由人」以「沉浮」状人生境遇之起伏，「兜转」摹命运轨迹之回环，二词已括尽世间百态。「尽由人」三字似含叹惋，亦藏观照：世人于红尘浪里辗转，或为外物所役，或被他力所牵，恰似风中蓬草，起落不由本心，荣枯穷达皆系于他人翻云覆雨之手，恍若孤舟漂荡而舵柄在握者非己。", "次句「倏忽摘取恣揉捏」，以「摘取」喻成果轻取，「恣揉捏」见恣意改塑之态：如巧匠裁云之锦突遭拆缦，妙手雕玉之工竟遇毁形，极写心血结晶遭外力无端改塑的荒诞——千般匠心构筑之境，瞬间化作可随意搓揉的泥团。「倏忽」写变易之骤如迅雷破寂，见美好建构遇无端揉碎的错愕，任其从「七宝楼台」沦为齑粉，尽失本然之质。", "第三句「心相泡影习成常」，深得佛理三昧。「心相泡影」化用《金刚经》「如梦幻泡影」之喻，言心识所执之相皆如露电无常；「习成常」非谓沉沦于虚妄，乃指诗人历经沧桑后，于诸相幻灭中修得「明知泡影而不怖」的定力——将幻灭视为常态，于无常中见真常。", "末句「始知交变叙事迭」收束全篇，以「交变」破恒常之执，以「叙事迭」明认知之变：因交接际会、时势迁转，方知世间万象本如川流不息，昔之圭臬今成故纸，彼之真章此作谬误，恰似史笔翻覆中自有春秋新解。「始知」二字如暮鼓晨钟，道破此际顿悟：当放下「常」之执念，方见万法皆流，本无住相，唯变易与视角重构是为永恒之律。", "全诗以「尽由人」之惑起，以「始知」之悟结，意象从「沉浮」的世相、「摘取」的痛感到「泡影」的哲思层层递进，哲思兼融释家「无常」、道家「变易」与现代认知哲学，于短短四句中构筑从现象到本质的思维跃迁。其笔致暗合传统诗学「意在言外」之旨，于古典形制中酿出现代哲思之芳醇，堪称「言有尽而意无穷」的诗性实践。")
  let asset = "assets/poems/流迁/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
= 压力阴郁
#text(size: 12pt)[本章收录 16 首。]
#pagebreak()
#{
  let title = "时机"
  let poem_lines = ("风云际会无好手，", "千里马来非佳期。", "熙熙攘攘不得志，", "形形色色难如一。")
  let context_note = "有感于个人能力/发展诉求与项目/团队需要在时机上的错位而作。"
  let commentary = ()
  let asset = "assets/poems/时机/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "补天"
  let poem_lines = ("每每功亏谁知苦，", "夙愿得偿笑颜开。", "累年残疾一朝愈，", "流失用户还复来。")
  let context_note = "修复历史悠久的线上问题所作。"
  let commentary = ()
  let asset = "assets/poems/补天/illustration.png"
  let override = ("还": "huán")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "劳疾"
  let poem_lines = ("苦营杂役形枯槁，", "重压潜流心焦颓。", "鸡血干货有时尽，", "执念愿景转成灰。")
  let context_note = "工作压力过大所作。"
  let commentary = ()
  let asset = "assets/poems/劳疾/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "多艰"
  let poem_lines = ("白日连轴转，", "夜晚噩梦缠。", "拿起庶几成，", "放下乱成团。")
  let context_note = "多艰之意分为事多、事艰。前两句说的是事情多，夜晚噩梦往往不是那些恐怖片桥段而是工作场景， 待办事项白日做不完以致入梦。"
  let commentary = ()
  let asset = "assets/poems/多艰/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "还家"
  let poem_lines = ("连轴苦战为年安，", "纷至迭来案无垠。", "身在樊笼心企渴，", "一朝放飞疚难平。")
  let context_note = "过年前忙完把工作交接给值班同事后回家过年路上所作。但其实因情况发展始料未及，年初三又赶回公司。"
  let commentary = ()
  let asset = "assets/poems/还家/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "肩钧"
  let poem_lines = ("扶犁耕新野，", "授将镇旧疆。", "奔走拨千斤，", "失察辛莫赎。")
  let context_note = "前两句的背景是需要兼顾新老团队和新老项目，老项目可更多授权，新项目则需要事必躬亲。后两句有感于自己在精力有限的情况下兼顾两端，担心出现疏漏造成不可弥补的问题。"
  let commentary = ()
  let asset = "assets/poems/肩钧/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "未竟"
  let poem_lines = ("殚精竭虑周不全，", "连迭赶忙未如期。", "年年规划竟半功，", "岁岁值守起新波。")
  let context_note = "有感于工作每个方面都只做了个半好而作。"
  let commentary = ()
  let asset = "assets/poems/未竟/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "低效"
  let poem_lines = ("勉力营馨难兑诺，", "案牍烦忧蚀图景。", "熙攘无处解孤渴，", "思华星火成烟烬。")
  let context_note = "由于未能很好地兼顾家庭与工作，更深地感受到个人的孤独而作。"
  let commentary = ()
  let asset = "assets/poems/低效/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "衣悟"
  let poem_lines = ("德责勉尽咎愧仍，", "两全难能何缚己。", "沧粟漂萍负块垒，", "不如一骑驰心野。")
  let context_note = "由于未能很好地兼顾家庭与工作，寻求洒脱的心境而作。"
  let commentary = ()
  let asset = "assets/poems/衣悟/illustration.png"
  let override = ("骑": "jì")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "岩浆"
  let poem_lines = ("时偿积欠缺填勉，", "凝途失涩兴阑珊。", "奔流方遒黯如没，", "趣中汲静思里安。")
  let context_note = "寻找支撑忙碌工作的动力而作。"
  let commentary = ("「岩浆」是埋在地表之下的剧烈活力，沉而不息——诗题选了这个词，给「保持支撑忙碌工作的动力」这件事，配了一个很深的地质隐喻。《岩浆》写的是忙碌之中，那股被堵住的驱动之力，会去到何处生息。", "「时偿积欠缺填勉」，逐字读来，全是债：时偿，是以时间为单位偿还；积欠，是积累的亏空；缺填，是将空缺一一补平；勉，是在勉强之中做完这一切。一行之内，没有一个动作是出于意愿，全是出于必须——这是被工作追着走的一天，做完了，不过是被追得又近了一步。", "「凝途失涩兴阑珊」，三个词，各自指向耗竭的一个层面。「凝途」是行进的感觉：路变得黏稠，向前如同趟过凝固之物，推力愈来愈费。「失涩」取古汉语因果结构，因涩而失——因阻滞之故，推进之力已然折损；不是有所得，而是在摩擦中有所失。「兴阑珊」取「意兴阑珊」之义，是兴致已走到了最低处，几乎所剩无几。", "「奔流方遒黯如没」，「奔流」是全诗第一次出现的正面动势——不是凝滞，不是失涩，是水流奔涌，力量在行进。「方遒」出自「书生意气，挥斥方遒」，是气势与力量到达顶峰时的状态，这里说奔流正当最盛。然而「黯如没」赫然接在顶峰之后：「没」字注音「mò」，取沉没、消入之义，是被吞入黑暗，而非由外而灭。这般反转，令人扼腕喟叹：奔流正在最盛处，内里却已黯然如沉。这正是因为前两句所描述的现实，将活力吞没——岩浆的冷却不只在表层，也渗往核心。", "「趣中汲静思里安」，前三句将压力与损耗逐层堆叠——债、凝途、失涩、阑珊、奔流暗没——读至此，诗境已沉至最深，几近无解，读者也随之有力竭之感。这一句不再加重，笔锋一转，给了一条出路。「汲」字取汲水之义，是将桶放入井里，主动提取；这里是从兴趣之中，将心静提取出来。「思里安」是最后的落点：在思索之中，让心绪安宁下来。", "从「勉」到「安」，全诗走了一段向内转的心路历程：动力耗竭，奔流至黯然时，深处尚有——趣与思的那一口井。")
  let asset = "assets/poems/岩浆/illustration.png"
  let override = ("没": "mò")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "望空"
  let poem_lines = ("立身荒谬耕心意，", "倾注殷切抹能轻。", "因果涟漪噬回还，", "于墟棘中缮草亭。")
  let context_note = "绸缪已久的规划被突发安排推翻，心中失落而作。"
  let commentary = ()
  let asset = "assets/poems/望空/illustration.png"
  let override = ("还": "huán")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "掌中"
  let poem_lines = ("势成相左湮持庸，", "幽阵摊推守驰驱。", "颠簸诡谲栖疏惬，", "井井施条焕遗墟。")
  let context_note = "在人际纷争中寻求内心平静而作。"
  let commentary = ()
  let asset = "assets/poems/掌中/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "齿轮"
  let poem_lines = ("念执临穴{\\textsf 洑}水行，", "触域及高知位险。", "十方错切拢散盘，", "千辛半阙耕寥田。")
  let context_note = "在凶险局势中寻求内心平静而作。"
  let commentary = ()
  let asset = "assets/poems/齿轮/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "井观"
  let poem_lines = ("遐瞻垂问计何定，", "款曲裁编众竭泽。", "曙影乍开天幕收，", "下稍究尽命无择。")
  let context_note = "有感于某业务前景难以挽回而作。此作用典较多，稍晦涩。"
  let commentary = ()
  let asset = "assets/poems/井观/illustration.png"
  let override = ("曲": "qǔ")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "沉沦"
  let poem_lines = ("食色惰慢七罪四，", "贪嗔疑虑五毒三。", "身沾万点尘世红，", "心缠半丝天际蓝。")
  let context_note = "有感于自己在人性缺陷中沉沦而作。"
  let commentary = ("《沉沦》以账目清算般的冷峻入诗——不辩白，不忏悔，只将身上的每一处沾染逐一点出。篇名「沉沦」，既是承认，也有着观察；能在沉沦之中保持清点的眼睛，本身就是这首诗最幽微的主旨。", "「食色惰慢七罪四」，基督教传统所列七宗罪通常为贪食、色欲、怠惰、傲慢、愤怒、贪婪、嫉妒七项；诗取其四：食（贪食）、色（色欲）、惰（怠惰）、慢（傲慢）。", "「贪嗔疑虑五毒三」，佛家五毒（贪、嗔、痴、慢、疑）中取三：贪、嗔、疑；「疑虑」二字合而写出疑念转为日常焦虑的状态。「慢」本亦在五毒之列，诗却已将其归于上一句的七宗罪——两套坐标共用一个词，诗不作辨析，悄然并置。七取其四、五取其三，不是随机的清点，是诗人对号入座，给出了一份惊心动魄的自供状。", "「身沾万点尘世红」里，「红」字浊重，取红尘之色，在佛道文学里比喻世间万象、欲念纷扰；「沾」字轻飘，取轻微沾染之义，异于全然浸没。尘世之红附于肌肤，尚未化入骨髓，隐含一线间距与余地。「万点」之众，不可计数，可见沾染之广。", "「心缠半丝天际蓝」，「缠」与「沾」不同：缠是双向的纠缠，不只是附着，更是彼此牵绊。「蓝」为天际之色，远而高，在这里象征清净与辽阔；心与天际蓝相缠，究竟是心在向蓝攀援，还是那一缕蓝在牵制着红尘，诗中未置可否。「半丝」之微，与「万点」之众相对，量词已悄然道出了悬殊。", "这首诗说到底是自画像，而非忏悔。忏悔者渴望洗清，自画像则力求无所遗漏。然而沉沦之中犹存「半丝天际蓝」，这便不是净化，而是并存——身与心、红与蓝、沾与缠，两种力量在同一个人里同时成立。诗人承认「沉沦」，不作解脱之许诺——不逃，不辩，亦不彻底绝望。", "很难因为这「半丝」就兴起多大挽救的希望，但这些微韧性久久不散，自是本性犹存。")
  let asset = "assets/poems/沉沦/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "席散"
  let poem_lines = ("萃聚一堂开新行，", "求索雕琢竟曲终。", "来途荏苒同舟济，", "前路依稀各乘风。")
  let context_note = "有感于业务调整尘埃落定、曾在一起的团队各奔前程而作。"
  let commentary = ()
  let asset = "assets/poems/席散/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
= 情感与家庭
#text(size: 12pt)[本章收录 6 首。]
#pagebreak()
#{
  let title = "心印"
  let poem_lines = ("盈盈倩影跃，", "嫣嫣美目盼。", "各归意伶俜，", "寤寐思身畔。")
  let context_note = "有所爱恋，有所思念而作。"
  let commentary = ("《心印》写的是一枚烙在心上的印记。题眼正在「印」字——所爱恋之人一旦入心，便如长久印痕。全诗从相见、相处之美，写至别后思念，印痕之深，渐次渗透。", "「盈盈倩影跃」，起句引入眼帘的首先是一个轻盈的身影。「盈盈」是叠字，状体态的柔婉娉婷，古诗十九首中「盈盈楼上女」即用其姿；「倩」字则暗接《硕人》「巧笑倩兮」，是顾盼生姿的美好。一个「跃」字尤为灵动：影不静立而轻跃，仿佛人仍在眼前走动，记忆里的身影也因这一跃而有了生气。", "「嫣嫣美目盼」，次句由身姿转到眉眼。「嫣嫣」状笑意之甜，与上句「盈盈」两组叠音前后相应，如同那一颦一笑萦回心头，挥之不去。「盼」字尤见用心：《硕人》「美目盼兮」本写黑白分明、流转有神的眼波，而「盼」又自含企盼之义；于是这一眼里既有她顾盼的明丽，也悄悄渗进了观者的盼望——美目流转之间，已先伏下了后两句的思念。", "「各归意伶俜」，第三句陡然一转，从相伴的明丽跌入独处的清冷。「各归」是两人各自归去，亦或是各有归宿。「伶俜」（líng pīng）状孤单无依、茕茕独行之态，那份没有着落的怅惘，萦绕不散。前两句越是盈盈嫣嫣，这一句的伶俜便越显清寂。", "「寤寐思身畔」，末句将思念收束于一个朴素的愿望。「寤寐」直承《关雎》「寤寐求之」——无论醒着还是睡着，那念头都不曾停歇。「身畔」落得朴实而具体：所盼者无非那个人就在身边、伸手可及的寻常；越是寻常，越显思念之切。", "四句之间，是一条由见到思的线：先有盈盈倩影、嫣嫣美目的惊艳，继而各自归去的清冷，终至寤寐不休的牵念。所恋之人自始至终未被直呼，只凭一影、一眼、一念被反复摩挲——所谓「心印」，正在于此：相聚或长或短，真正留下的，是那个人在心上按下、洗不去的一枚印。")
  let asset = "assets/poems/心印/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "夜会"
  let poem_lines = ("别前相约衷情诉，", "厮磨飞霞染耳梢。", "托付此心长久远，", "怎堪行去念思滔。")
  let context_note = "别前相见后，启程途中回想所作。"
  let commentary = ("《夜会》一诗，以简洁而深情的笔触，生动地描绘了恋人在分别前夕夜会的场景，细腻地展现出其间复杂而浓烈的情感，宛如一首动人心弦的恋曲。落笔时人已启程，写的是途中对那一夜的回想——相会刚过，思念正浓。", "首句「别前相约衷情诉」，「别前」直接点明背景：分别在即，两颗心想再抓住最后亲近的机会，才有了这一次「相约」，氛围中略带忧伤与珍重。「衷情诉」三字，将恋人之间那种毫无保留、倾诉肺腑的深情刻画得入木三分，空气中弥漫着不舍与眷恋。", "「厮磨飞霞染耳梢」，此句以体贴入微的描写，将恋人之间亲昵的互动展现得真切动人。「厮磨」一词，鲜活地呈现出两人相互依偎、情意绵绵的甜蜜姿态。「飞霞」将恋人因亲密接触而泛起的羞涩红晕，比作天边绚烂的云霞，而妙在落点偏在「耳梢」——羞意藏不住，悄悄红到了耳尖。一个「染」字更是把那抹红写得缓而匀，像霞色一点点晕开。这不仅勾勒出一幅极具美感的画面，更细致地传达出人物内心的娇羞与甜蜜，浓郁的爱意在两人之间流淌。", "「托付此心长久远」，情感在此处进一步升华。在这离别的特殊时刻，两位恋人将自己的真心诚挚地「托付」给对方，表达了对这份爱情能够跨越时空、长久永恒的美好期许。前两句的倾诉与厮磨还系在眼前的一夜，此句两人的心却已飞到了岁月深处。", "尾句「怎堪行去念思滔」，笔锋一转，从对爱情的托付陡然过渡到对分别后思念的忧虑。「怎堪」二字，强烈地表达出主人公难以承受分离之苦的心境。「行去」是正在远行、一步步离她而去，而「念思滔」则形象地描绘出一旦分别，思念便如滔滔江水般汹涌而来，无法遏制。这一句将主人公对离别之后那无尽思念的担忧写得淋漓尽致，使诗歌情感的纵深也由此推开，展现出爱情在面对离别时的无奈与深沉。", "整首诗语言质朴自然，却饱含深情。通过对夜会场景的传神描摹以及情感的微妙转变，从甜蜜的相聚、郑重的托付，到行去途中的思念奔涌，层层递进地展现了恋人之间幽微而真挚的情感。")
  let asset = "assets/poems/夜会/illustration.png"
  let override = ("长": "cháng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "心意"
  let poem_lines = ("唇间春意露，", "身后臂膀环。", "安居甜蜜意，", "携手浪迹心。")
  let context_note = "世间男女偶遇相恋后，虽情意绵绵，心中所憧憬的，却是不一样的幸福。小龙女要的是终老古墓，杨过要的是携手浪迹天涯。女性常以家庭为终极价值、归宿，男性以家庭为事业生涯的基石、港湾。这种爱恋的引力和心意的相背，构成了长期相处的张力。于花市看见一对甜蜜情侣，心有感而作。"
  let commentary = ("花市中一对相依的恋人，本是春日里平常的一瞥；诗人从这一瞥里看出了更深的东西。相恋之初，亲近在眉目唇齿与环身依偎之间显露无遗；至于这份亲近要发展成怎样的形态，此刻尚未分明。《心意》所写，是两人心中同有一份爱，却各有其幸福图景。", "「唇间春意露」起得很轻，只落在「唇间」，并不点明微笑或是轻吻。「春意」既承花市之春，又写恋人面上流露出来的情投意合。春色于是从花上染到人上。", "「身后臂膀环」，镜头从唇际，略过耳侧，移向身后。「身后」二字有亲密中的放心：被环住者不必回望，已经知道来者是谁。「环」又比「抱」更有形，像臂膀围成一个小小的所在，把喧闹周遭暂时隔在外面。前句所写的情意浮现，原来正是因为此句所写的相依。果先入镜，再揭示其因，因果相互印证之下，两人之亲近，读者感受更深一层。", "「安居甜蜜意」引出怀中的她心中更长久的愿望。「安居」二字平稳而深远，「安」是心有所定，「居」是身有所归；「甜蜜」到了这里，便由片刻爱恋，转为可以长相厮守的支点。诗人在创作背景中提到小龙女愿终老古墓的情节，正是女性一方把爱恋收为归宿的心意。", "「携手浪迹心」则转到他心中关于未来的畅想。「携手」仍是两个人，正见其情意不减；「浪迹」一出，脚步便不肯停在屋檐之下。他所向往的，是与所爱之人同历山河、同经风雨。诗人在创作背景中提到杨过浪迹天涯的情节，正在这里化为男性一方的心声。", "如此再看前二句的亲昵，便有了甜蜜之外的深意。唇间春意与身后臂膀，写的是当下同在；安居与浪迹，写的是同在之后她与他对关系的两种想象。诗中没有让二人争辩，也没有把差异写成伤痕，只把「意」与「心」安放在相邻的两句里：她愿把春意留成家常，他愿携此春意走向未知的远方。", "花市人声俱在，臂膀仍环抱着，唇间春意也正浓，此景定格，刹那永恒；她所珍惜的安顿，他所向往的同行，却都留给了读者去遐想。")
  let asset = "assets/poems/心意/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "喜临"
  let poem_lines = ("同事儿女接连诞，", "意犹忐忑羡天伦。", "忽如一夜豆发芽，", "山花烂漫面春风。")
  let context_note = "妻子有喜所作。"
  let commentary = ("《喜临》之「喜」取「有喜」之意。全诗从喜讯来临前的期待与不确定起笔，衬托出喜讯突至时全面绽放的心情。", "「同事儿女接连诞」，起句先写他人之喜。「同事」为平日共事之人，他们的经历最令人联想自身。下一代「接连诞」生，对自身是当下的反衬，也是对未来的预演，对内心的冲击一点点积累起来。", "「意犹忐忑羡天伦」，第二句落回己身。一个「犹」字对比上句中的已经成为过来人的他人，自己内心仍然「忐忑」不定，但内心深处是隐约期待的。「羡」字坦诚揭示了期待背后的心理动因，乃是落在「天伦」之乐上。两句铺垫下来，读者不由也深深代入等待未知的矛盾心态。", "「忽如一夜豆发芽」，第三句骤然揭晓喜讯。「忽如一夜」承自岑参「忽如一夜春风来，千树万树梨花开」的句式，借来塞外降雪之喜。「豆发芽」三字含蓄而形象，「豆」暗含「种豆」的前情提要，「发芽」则以苗芽的萌动比喻新生。此句体感里，喜讯又轻又小，亦给人惊喜。", "「山花烂漫面春风」，第四句再承岑参句中春风之意，将微小的惊喜扬开洒满。「山花烂漫」在得知喜讯的父母周围，渲染出群花盛开的繁丽，以状此刻心中仪式感之盛况。「面春风」则直写父母面庞上那像春天般洋溢着生命力与期许的喜悦。此句铺开诺大场面，与第三句「豆发芽」的微小形成体量上的反差：一粒小小豆芽，在父母心中，绽放出漫山遍野的花海。", "四句的情态由远而近、由微而盛：他人之喜——自身之忐忑——一夜之芽——漫山之花。前两句蓄足旁观与犹豫，后两句骤然释放，极富感染力。")
  let asset = "assets/poems/喜临/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "十月"
  let poem_lines = ("纸迹浅浅映愿深，孕吐翻腾喜含酸。", "唐筛排查换心宽，四维彩超初见形。", "萌童海报环四壁，典乐诗谣开鸿蒙。", "腹隆曲美留存照，五谷杂粮控血糖。", "腰背腿疼卧难安，胎动如悸渐踢蹬。", "脐绕不再位已正，入盆待命盼宫缩。")
  let context_note = "妻子十月怀孕所作。"
  let commentary = ("记孕之诗多止于喜悦或期待，《十月》却以六联十二句逐月铺陈，从产检纸单写到入盆待产，将十个月的等待编织成一份可触的时间表。诗人不避现代医学语汇，「唐筛」「四维彩超」「血糖」与「鸿蒙」「天伦」并置，构成全诗最特别的肌理：科学与古典在同一句法骨架里共栖。", "「纸迹浅浅映愿深，孕吐翻腾喜含酸」，起联即以一对偶呈现整诗的基调：试纸的两道痕色虽浅，所反映的心愿却深；孕吐的生理翻腾，裹着喜讯的甜。「映」字与「含」字颇有张力，前者以外物之证写得偿的心愿，后者以生理比喻复杂心情。还是萌芽的新生命在此联中，发出了宣告自身存在的强烈信号。", "「唐筛排查换心宽，四维彩超初见形」，第二联进入产检序列。「换心宽」三字将抽象的忐忑具象为一桩交易——以排查的细致到位换取担心的宽舒。后半句则是胎儿在「四维彩超」的仪器检查之下初次显出轮廓。「初」字尤为传神，写出了父母朦胧的期待被亲见具象化时的全新感受。起句见迹，此句呈形，这两句一出，一个健康而又有形会动的胎儿，跃然纸上。", "「萌童海报环四壁，典乐诗谣开鸿蒙」，第三联地点上从医院回到家中，时间上也默然推进。「萌童海报」投射着父母对孩子出生后形象的想象，「典乐诗谣」则沁透了父母在胎教中寄予的深切厚望。「鸿蒙」二字源出《庄子·在宥》，指天地未分之初的混沌之气。诗人将胎教置于一个庄学命题之内：尚未出生的生命，如鸿蒙之气，正待被音乐与诗谣开启。家居一壁与天地一气，在这两句中合为一处。", "「腹隆曲美留存照，五谷杂粮控血糖」，第四联着眼于母亲的身体。「腹隆曲美」写出胎儿的成长，「留存照」也为怀孕身形留下纪念性影像。下句的「五谷杂粮控血糖」则转入饮食管理的日常细节：母亲的身体既有可被欣赏、纪念之美，更是需要被悉心照护的生命。", "「腰背腿疼卧难安，胎动如悸渐踢蹬」，第五联是最辛苦的一联。三处疼痛并举，再以「卧难安」写出对母亲休息与心情的折磨，孕期后段的身体仿佛不再属于自己。下句的「胎动如悸」把胎儿的动作译为母性的悸动，胎动既是惊喜又是心跳，每次都是喜惊参半。「渐踢蹬」三字示出力度的递增：从如悸而至踢蹬，胎儿的存在感一日强于一日，健康活力亦可见一般。", "「脐绕不再位已正，入盆待命盼宫缩」，末联收束于产前最后阶段。「脐绕不再」「位已正」是两件让父母心安的医学小确信，「入盆」与「待命」则把妊娠晚期的胎儿想象为整装待发之态——「待命」二字带来一丝出发前的紧张感。「盼宫缩」三字换到大人视角，以「盼」字收全诗：所有十个月的铺陈，都凝聚未于这最后关键的当口。", "六联从两道试纸痕色一路写到入盆，时间从无形的「映」走到具形的「待命」。诗人以「喜含酸」起、以「盼宫缩」结，写出了十月经历的时光——翻腾、见形、控糖、悸动、入盆，新生儿的孕育不只是幸福的酝酿，更是被母亲身体承担的复合历程，诗人以切肤的笔触，写出了深切的关爱。")
  let asset = "assets/poems/十月/illustration.png"
  let override = ("迹": "jì", "吐": "tù", "乐": "yuè", "血": "xuě")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "疹热"
  let poem_lines = ("反侧眠未安，", "煎熬口难言。", "楚泪湿枕席，", "内焚红耳弯。", "父母千重忧，", "诊者一言宽。", "轻身脱病沼，", "复享天伦欢。")
  let context_note = "女儿发热所作。"
  let commentary = ("《疹热》记的是女儿一场高热里的一夜。题中「疹热」预先揭晓了病因，然而过程中高热症状的每一个变化，都牵动着父母的心。全诗八句五言，句句皆是这般惊心动魄。", "「反侧眠未安」，起句先写病中孩子的辗转。「反侧」暗接《关雎》「辗转反侧」，本状忧思难寐；移于此处，是高热中的小儿翻来覆去、睡难安稳。「未安」二字尤见揪心：夜已深，而孩子和父母都未得安宁。", "「煎熬口难言」，次句写苦之无从诉说。「煎熬」本是火上熬煮，用来写高热灼身贴切不过——孩子尚小，病里的难受说不出，只能由这两个字替他熬着。「口难言」道出稚子有苦难言的无助，也暗含父母看在眼里、问不出缘由的焦灼。", "「楚泪湿枕席」，第三句落到一个具体的画面。「楚」字状泪之凄苦，给泪水多染上一层切肤之痛；泪水浸湿枕席，未写一声啼哭，孩子病中的委屈却已尽在其中。", "「内焚红耳弯」，第四句把高热写到了肌肤上。「内焚」是热自体内焚烧，「红耳弯」则是这焚烧透到了表面——耳廓泛红，是父母俯身细看留意到的细节。一内一外，体温的炙烈与父母的关切，都在这五个字里。", "「父母千重忧」，五句由孩子转到床前的大人。「重」（ chóng），此处是层叠之义：千重忧，正是忧虑一层叠着一层——怕烧得更高，怕夜里生变，层层累加。这一句不再借物象侧写，直点「父母」之「忧」，是全诗情感的正面。", "「诊者一言宽」，六句是全诗的转机，也与上句对得工整：「千重」对「一言」，「忧」对「宽」——千层的担忧，被医者一句话宽解。数目上的千与一、分量上的忧与宽两相对照，诊者那一句宽心便格外有力，一夜的惊惧到此落地。或是病因中的，或是下药对症，医者功德无量。", "「轻身脱病沼」，七句写病愈。「病沼」把疾病喻作泥沼，缠陷难出；「脱」字一出，便有挣脱泥淖、重见干爽的轻快。「轻身」二字尤好：病时身重，愈后身轻，体感的转变里全是如释重负的欢喜。", "「复享天伦欢」，末句收于一个「复」字。「复」是重新、再度——病来之前的合家之乐被这场高热打断，如今失而复得。「天伦欢」三字，把一夜揪心的终点落在寻常而珍贵的天伦之乐上：孩子好了，阖家安乐。", "八句循着一夜的起落：孩子病中的辗转与泪水，父母层叠加重的忧虑，诊断的宽心，终以病愈、家欢为圆满结局。全诗未曾呼喊诉苦，只凭一幕幕病中细节，便递出为人父母的况味——孩子身上一点热，是全家心上一场熬；热退之后，那寻常的天伦之乐，感受上便是珍贵的失而复得。")
  let asset = "assets/poems/疹热/illustration.png"
  let override = ("重": "chóng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
= 哲思禅意
#text(size: 12pt)[本章收录 4 首。]
#pagebreak()
#{
  let title = "孤僧"
  let poem_lines = ("花市灯华人如潮，", "我缀其中如孤僧。", "皮色红尘愿尽历，", "只求得透空中道。")
  let context_note = "春节花市所作。"
  let commentary = ("春节花市，人声鼎沸，灯火辉煌——这本是红尘最有人间烟火味的场合。《孤僧》在这里站定，既不出离，也不融入，只是目光所向、思绪所至，与周遭氛围迥然不同。", "「花市灯华人如潮」，起句全是外景：花，灯，人，潮。「华」字取光华、灯华之义，是灯光映照下万物生辉的那种亮；「人如潮」是春节花市最真实的感受，人流涌动，身不由己。这一句只是如实呈现了一个喜庆热闹的情境，形成对后文的衬托。", "「我缀其中如孤僧」，从外景转向内景，诗人交代了自己在这潮流中所处的位置。「缀」字取悬缀、附缀之义，是轻附于上的状态——有所附着，却未曾沉入。「孤僧」是比喻，也是一个传统意象：在禅宗与唐诗的脉络里，孤僧往往是那个穿行于世间而不为世间所动的人，既在场，又独立。春节花市，与此意象相遇，构成了一种若即若离的张力。", "「皮色红尘愿尽历」，这句最见诗人态度。「红尘」是佛学常用语，指色相纷呈的现象世界；「尽历」是愿意全部经历，一样不落。「皮色」二字最为凝练：「皮」取皮相、表层之义，「色」取佛学五蕴之色（梵文 rūpa），即一切可见的形相；「皮色」合而读，是这个世界的表色之层——诗人愿意经历的，正是这一层层的色相显现。「愿」字最重：是主动的选择，将这一切都经历过去，而非无奈随缘。这句话实是对通常「出世」逻辑的一个反转：孤僧不逃离红尘，孤僧愿意把红尘历遍。", "「只求得透空中道」，是全诗的落点，也是唯一的诉求。「透」字取透穿之义，仿若目光穿入而见底，仍立于红尘墙前。此句的断句是：得透「空」，于「空」中见「道」——「空」是佛学的空性（梵文 śūnyatā），指一切现象皆无固有自性的实相；「道」是道家所言的道，是穿透空性之后所见的路向。「空中道」三字，将佛家的空与道家的道并置。「只求」二字，将「愿尽历」与「得透道」并置：前者是进入，后者是见到；历遍皮色，穿入空性，然后在空性之中，得见大道。", "全诗的重心在「愿」字——主动选择进入，把这一切都经历过去，然后在其中见底。孤僧身处花市，人如潮，灯如华，他一一领受，只是目光已穿过这一切。")
  let asset = "assets/poems/孤僧/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "花泥"
  let poem_lines = ("世间本来无有我，", "何必以我求忘我。", "悲喜触识着此在，", "百年之后化花泥。")
  let context_note = "见“求忘我”语所作。"
  let commentary = ()
  let asset = "assets/poems/花泥/illustration.png"
  let override = ("着": "zhuó")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "自然"
  let poem_lines = ("何智逐尘功，", "本真望莫渴。", "求索生新梦，", "实相在心豁。")
  let context_note = "采撷意译创作自叶芝的诗："
  let commentary = ()
  let asset = "assets/poems/自然/illustration.png"
  let override = ("相": "xiàng", "豁": "huò")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "觉来"
  let poem_lines = ("吾侪心事长流水，", "停觞自醉梦渊明。", "富贵无味不应堪，", "东山饶起为苍生。")
  let context_note = "以出世之心境入世，从辛弃疾《水龙吟·老来曾识渊明》中采字所作。"
  let commentary = ()
  let asset = "assets/poems/觉来/illustration.png"
  let override = ("长": "cháng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
= 心情与事件
#text(size: 12pt)[本章收录 18 首。]
#pagebreak()
#{
  let title = "相寻"
  let poem_lines = ("走马前边行，", "流连人没漫。", "众里茫相寻，", "一枝蝴蝶颤。")
  let context_note = "花市人多走散寻回所作。取“众里寻他千百度，蓦然回首，那人却在，灯火阑珊处”的意境。"
  let commentary = ()
  let asset = "assets/poems/相寻/illustration.png"
  let override = ("没": "mò")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "年心"
  let poem_lines = ("冬寒指日还春暖，", "雨雾朦胧先润街。", "年心似箭佳期近，", "一岁枯荣在此节。")
  let context_note = "去超市一趟所作。这还没到春节呢，雨就开始斜斜地下，周围的建筑物都笼罩在雾中，空气清新湿润，带来春意。盼着过年放假的心情，今年已不剩几天。古时，年过得好坏定调一年的年景，而现在，明年的战略项目Q1迭代也到了关键节点。"
  let commentary = ()
  let asset = "assets/poems/年心/illustration.png"
  let override = ("还": "huán")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "园校"
  let poem_lines = ("徐风草荷香，", "迟波逸思漾。", "叶雨洒苔阶，", "抚卷掩幽肠。")
  let context_note = "流连母校老校区所作。"
  let commentary = ()
  let asset = "assets/poems/园校/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "心屿"
  let poem_lines = ("境迁人杳梦未离，", "访友抚琴感旧迹。", "纷繁汪洋留心屿，", "苍茫四顾慰孤旗。")
  let context_note = "访友忆昔所作。"
  let commentary = ()
  let asset = "assets/poems/心屿/illustration.png"
  let override = ("迹": "jì")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "心花"
  let poem_lines = ("花开招展冬日春，", "琉璃如镜映影只。", "心思渴望逾墙去，", "此身仍在樊笼中。")
  let context_note = "看到朋友圈上一张阳台上的花的照片，评论时随意所作。可按在职场里想象外出创业来理解。"
  let commentary = ()
  let asset = "assets/poems/心花/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "启步"
  let poem_lines = ("脂重乏肌显体圆，志虚轻誓总断延。", "鞋环衣裤皆齐备，东风乍起旗又偃。", "午间会后健房满，晨床迟起无澡时。", "轻装放空入夜丛，野径路灯伴胖影。", "汗酣血活心宇阔，设标昂首越路人。", "面红气短歇不停，耳乐恢宏重拾步。", "踝适膝承喘渐平，脚下里程腋成裘。", "配速虽缓阶踏实，此战持久莫急求。")
  let context_note = "夜跑减重所作。"
  let commentary = ()
  let asset = "assets/poems/启步/illustration.png"
  let override = ("血": "xuě", "重": "chóng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "尝假"
  let poem_lines = ("宏愿浅酬临绛海，", "千钧垂悬稍息拼。", "值此闲景忘紧弦，", "夕霞新月淌悦欣。")
  let context_note = "十一长假，中间捞少数几天，短途旅游，浅浅品尝这长假。"
  let commentary = ()
  let asset = "assets/poems/尝假/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "咏茶"
  let poem_lines = ("色秋胃暖齿间辽，", "壶引杯倾津汇滔。", "遍采千株晨滴露，", "幽腔远注洗心曹。")
  let context_note = "心中积郁，饮茶得解而作。"
  let commentary = ()
  let asset = "assets/poems/咏茶/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "咏酒"
  let poem_lines = ("满壶倾故事，", "杯盏碰心声。", "此物最忘情，", "虽醒犹忡怔。")
  let context_note = "醒酒所作。"
  let commentary = ()
  let asset = "assets/poems/咏酒/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "鱼缸"
  let poem_lines = ("敦身鳍缓箭穿梭，", "高游低栖尽资餐。", "但有海神立星国，", "扬鳞同销万古难。")
  let context_note = "吃海鲜前于鱼缸中见大鱼生猛姿态，有感于族类不被圈养役使有赖于强者而作。"
  let commentary = ()
  let asset = "assets/poems/鱼缸/illustration.png"
  let override = ("难": "nàn")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "羽决"
  let poem_lines = ("碳框弹杆趁手柄，", "虎口以力拇指巧。", "移步顺腰肩背耸，", "臂挥腕送掌心饱。", "开肢侧身面球轨，", "九宫八向切拍挑。", "太极圆柔咏春袭，", "五禽起伏金箍绞。")
  let context_note = "使羽毛球拍如有剑诀所作。"
  let commentary = ()
  let asset = "assets/poems/羽决/illustration.png"
  let override = ("弹": "tán", "挑": "tiǎo")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "得遇"
  let poem_lines = ("岁月侵蚀人微渺，", "褴褛凡衫挂挺枝。", "何逢契魂由衷励，", "残损抚遍心伤弥。")
  let context_note = "有感于蹉跎岁月中得遇知己，采撷意译创作自叶芝的诗："
  let commentary = ()
  let asset = "assets/poems/得遇/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "出戏"
  let poem_lines = ("层峦碧嶂雪狮欢，", "暖浪濯足惊溅寒。", "潮去漩{\\textsf 洑}陷泥滩，", "风来意阔尘嚣安。")
  let context_note = "海边休假戏水，暂时出脱释怀所作。"
  let commentary = ()
  let asset = "assets/poems/出戏/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "滋长"
  let poem_lines = ("迥廊椰玉柱，", "藤叶翠扶疏。", "柔蔓垂萦纡，", "谁知雨前初？")
  let context_note = "雨中漫步绿廊，有感于人际故事缘起而作。"
  let commentary = ()
  let asset = "assets/poems/滋长/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "遴选"
  let poem_lines = ("较艺抡材衡鉴内，", "丹忱筋韧网罗中。", "欣逢翘楚登时纳，", "排布分忧共僦功。")
  let context_note = "在“旰宵汲汲”与“夙夜孜孜”中给专场招聘会的寄语，改写自宋·赵恒《又将放榜》，用典较多。"
  let commentary = ()
  let asset = "assets/poems/遴选/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "纵擒"
  let poem_lines = ("犁滩浪袭贝踪现，", "蚌蠕壳扬钻深忙。", "眼疾步挪手啄沙，", "掌心翻覆返海乡。")
  let context_note = "海边拾贝所作。"
  let commentary = ()
  let asset = "assets/poems/纵擒/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "哧溜"
  let poem_lines = ("恢恢扑蝶网，", "悠悠淌冰溪。", "浅底现形迹，", "倏而没湍泥。")
  let context_note = "溯溪捉鱼所作。"
  let commentary = ("溯溪捉鱼，特别适合假日放松。《哧溜》将这个场景描绘得有声有色，开头的郑重其事，对比结局的反差，正是其有趣之处。", "「恢恢扑蝶网」，「恢恢」本是老子「天网恢恢，疏而不漏」的笔意，形容法网庄严广大、无所不及；这里用来修饰一张扑蝶的网。宇宙法网骤然缩成了捕鱼工具，规格不符，但持网者的气势分毫未减。「扑」字取扑打蝴蝶的动作，带着那种对准了目标猛然一扑的姿势——装备与场合皆不对，但认真劲儿是真的。", "「悠悠淌冰溪」，上一句「扑」是迅猛出击，这一句「淌」是舒缓自怡——狩猎者持着大网，却走得悠然，在冰冷的溪水里慢慢趟行。「冰溪」是触觉，水温刺骨，而人不急；「悠悠」是步伐，是心态，也是这段溯溪路上的时间感，蓄住了上一句中的扑势。此时，还毫无猎物的踪迹。", "「浅底现形迹」，「迹」字注音「jì」，取踪迹、形影之义；「形迹」合而为词，是身形与游走之痕一并呈于眼前——不止是鱼，连鱼走过的路线都白白现了出来。「浅」是关键：浅则水清，水清则无处藏身；整条溪的能见度，在这一句到达顶峰。「现」字取主动态，不是捕鱼者看见了鱼，而是鱼自己现了身，似乎自己送上门来。然而这句里没有人的动作——网在手，人未动，只有鱼在那里，临时地、完整地现着。这是全诗节奏最静、张力最紧的一刻；下一句的「湍泥」将把这份清透彻底收走。", "「倏而没湍泥」，「倏」字快到无可计量，比「忽然」更急，几乎没有时间意识到发生了什么；「没」字注音「mò」，取沉没、消入之义，鱼一头钻进湍急的泥底，不见了。前一句浅底、明，这一句湍泥、浑——能见度骤然归零。诗名「哧溜」就是从「现」到「没」这之间，那一个还没来得及反应的瞬间。", "这首诗从「恢恢」的庄严到「哧溜」的一声，一路降维：宇宙级别的网，遭遇了溪底一条鱼；浩荡的准备，换来浅底惊鸿一现，然后再无痕迹。诗中既不惋惜，也不解释，只把落差交给读者感受。", "鱼走了，人还在溪里站着，手上那张网，依旧恢恢。")
  let asset = "assets/poems/哧溜/illustration.png"
  let override = ("迹": "jì", "没": "mò")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "穿越"
  let poem_lines = ("上下崎岖险山路，", "漫漫嶙峋乱石滩。", "此役竟可毕其功，", "手足相抵过蹒跚。")
  let context_note = "东西涌穿越所作。"
  let commentary = ("此诗以简劲笔墨勾勒跋涉之境，虽无唐诗之格律工稳，却深得古风之筋骨，于平易中见筋骨，于写实处寓深慨。全诗四句，如一幅山水速写，既绘险途之艰，复见心志之毅，读来令人惕然有感。", "首句「上下崎岖险山路」，起笔便见筋骨。「上下」二字，状山路之起伏跌宕，非平面之蜿蜒，而是立体之盘曲，暗含攀登之俯仰艰辛；「崎岖」「险」二词叠用，前者绘其形，后者状其质，短短七字，已将行路难之象铺陈殆尽。", "次句「漫漫嶙峋乱石滩」，承前拓展境界：「漫漫」写其辽远无终，见征途之长；「嶙峋」摹石之突兀，见滩途之险。山与滩，一纵一横，一高一下，共同构成立体的跋涉场景，字里行间似有足音磔磔，回响于荒寒之境。", "三句「此役竟可毕其功」笔锋陡转，由景及情，以「竟」字传递出劫后余生的慨叹。「此役」二字，将寻常穿越升华为一场「战役」，见跋涉之艰难若临战阵；「毕其功」则暗含「毕其功于一役」之典，却反其道而用之，非言急功近利，而是谓千难万险竟在此役中一朝跨越，语气中既有对前路之不测，更有对终竟其功的欣慰与释然。", "末句「手足相抵过蹒跚」收束全篇，聚焦细节：「手足相抵」，既写登山时手脚并用之态，复暗喻同伴相扶持之谊，见跋涉非一人之勇，而需众力相济；「蹒跚」状步之不稳，与前文「崎岖」「嶙峋」相呼应，却以「过」字收束，见虽蹒跚而终得逾越，艰难中见坚韧，困顿中见希望。", "全诗章法谨严，前两句造势，后两句抒怀，以「险山路」「乱石滩」为背景，以「手足相抵」为关捩，将自然之险与人力之毅熔于一炉。语言质实而富张力，「上下」「漫漫」见空间之阔大，「嶙峋」「蹒跚」见物象之精微，大小相形，疏密有致。结句尤耐寻味：「手足相抵」四字，既写形之迫近，更写心之相契，使「穿越」一事超越物理层面，成为精神协作的象征。诗中无一字言情，而情自深；无一言明志，而志自显，深得「状难写之景如在目前，含不尽之意见于言外」之妙。", "读此诗，仿佛见一队行人在苍岩乱石间辗转前行，足踝触砾，掌心抵石，喘息与共，相扶以进。其写穿越之艰，实写人生之途——世路多歧，险滩难料，然人心相抵，终能蹒跚以过。此中真意，正合古人「岂曰无衣？与子同袍」之谊，亦见今人共克时艰之慨，于浅白处见厚重，于叙事中见哲思，殊为耐品。")
  let asset = "assets/poems/穿越/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
= 云南丽江香格里拉之旅
#text(size: 12pt)[本章收录 10 首。]
#pagebreak()
#{
  let title = "结游"
  let poem_lines = ("行轨攀梯程如网，", "即乘云鹤下江川。", "水影青赤入眼帘，", "旅伴鱼乐出豁然。")
  let context_note = "出游前想象所作。"
  let commentary = ("出游之诗多为行后追记，此篇却反其道而行，落笔于未发之前，以想象代替经历，将一程尚未踏足的旅途铺展为心中既成的画卷。四句读下来，恰是一道由密而疏、由地而天、由筹划而放旷的弧线，令人既期待这段旅途，亦为诗人的想象力所感染。", "「行轨攀梯程如网」起句不写风景，而写行程规划。「行轨」兼有轨道与行程之意，「攀梯」则见道路层层攀升之势，二者叠合，已是纵横交错。末三字「程如网」以一「网」字作结，此去日程线路之密集、筹划之周折尽在其中。", "「即乘云鹤下江川」中的「即」字陡然提速，仿佛诗人瞬间已从坐看行程规划的原地，化作云鹤凌空，目的地的山河已出现在眼下。「云鹤」本是仙家乘驾的古典意象，此处借以状飞行之高远。一「下」字与前句「攀」字形成反向，攀是地面的艰难筹备，下是凌空的自在抵达，二句之间，跳跃如斯，读者就此随着诗人轻巧翻飞，跨越莫大距离。", "「水影青赤入眼帘」，从凌空骤然落至水面，画面由天际收入湖色。「青赤」二色并举，或为湖水的碧蓝与山花的红艳在水中交映，四个字便将斑斓景色带至读者眼前。「入眼帘」三字颇具动感：眼帘本是眼皮的雅称，景色入眼帘，犹言画面自行掀帘而入——人未主动去看，色彩已扑面而来。", "「旅伴鱼乐出豁然」收句将同行之人与庄子笔下的游鱼并置。「鱼乐」二字出自《庄子·秋水》中「子非鱼，安知鱼之乐」的著名辩难，庄子不辩而知鱼乐，此处诗人亦不待出行便预知旅伴之乐，两重「未至而先知」彼此呼应。「豁然」则遥接陶渊明「豁然开朗」之意——穿过狭处，忽见天地敞亮。以「出豁然」作结，一「出」字兼有走出与涌出之意，仿佛人与喜悦同时从逼仄的日常中脱身而出。", "全诗自「网」始，至「豁然」终，仿佛一根鱼线划过长空放飞而出。路网、飞渡、水色、鱼乐，四帧画面各有质地，又依想象的逻辑自然排列——网中的繁琐换来腾空的自在，腾空的自在换来水色的扑面，水色的扑面换来鱼乐的感通。", "这是出发前心中那个完整的版本，尚未经历任何旅途的修改。诗人未到达，期待竟已圆满。")
  let asset = "assets/poems/结游/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "穿云"
  let poem_lines = ("鹤高白毯铺，", "俯首雪山冲。", "浅探绒棉绕，", "身投薄纱融。")
  let context_note = "乘机降落时观云所作。"
  let commentary = ()
  let asset = "assets/poems/穿云/illustration.png"
  let override = ("冲": "chòng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "盘山"
  let poem_lines = ("葳蕤丛接天，", "滂沛褶流泥。", "崖下江潺{\\textsf 湲}，", "峰间路迢递。")
  let context_note = "盘山公路上所作。"
  let commentary = ("盘山公路行于山腰，山色从四面涌来，每一处转弯都是另一帧画面。诗人以四句分别摄取，意象质地各异，词语亦生硬峭拔，如同山路本身的质感。", "「葳蕤丛接天」，「葳蕤」（wēi ruí）状植物繁茂而带拖曳之态，比「茂密」多了一份垂覆的动感，丛聚已接天际，植被之密几乎遮断了天与地之间的界限。「接」字比之于「连」，另含两端相触之意，且有主动性，丛木仿佛探向上方，欲与天际相衔接。此句视角朝上，先以植被的充盈确立山野的气势。", "「滂沛褶流泥」，「滂沛」（pāng pèi）本写雨水奔涌之势，此处移用于山坡泥流，将降雨的量感赋予了流动的泥土。「褶」字尤为特出——褶本指织物之折皱，用在山坡，既写地形折叠之态，也写雨后坡面泥流皱纹般的纹理。此句视线转向侧方，山体的皱褶与泥流的流动共构一幅湿重的横截面。", "「崖下江潺湲」，画面由侧向俯，崖壁之下，江流有声。「潺湲」（chán yuán）形容流水声绵长不断，「湲」字尤为罕见，较之「潺潺」或「流淌」，潺湲之声更绵长，有穿山跨谷之远感；此句视线探到崖下，画面亦有了声音。", "「峰间路迢递」，「迢递」（tiáo dì）写路途遥远而曲折，较「蜿蜒」「遥远」更兼有层峦叠嶂之间道路那种连续不断的延伸感。此句给出了盘山公路的全景，视线望向前方：盘桓的山路夹绕于两峰之间，极目远眺，仍不见终点。", "四句依次摄取上（树冠接天）、侧（泥坡流褶）、下（崖底江声）、前（峰间远路）四个方向的画面，是一次行进中的四顾。「葳蕤」「滂沛」「潺湲」「迢递」四组意象绵延相接，恰似行车时窗外景物一帧帧推移的质感。", "「迢递」以不尽的延伸作结，公路在峰间继续，诗止于此，路尚未止。")
  let asset = "assets/poems/盘山/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "观湖"
  let poem_lines = ("湿雨沁心肺，", "和风织锦纹。", "岛洲横镜浦，", "松影翠氤氲。")
  let context_note = "于观景台观泸沽湖所作。"
  let commentary = ("多数山水诗自目光起笔，此诗却从身体触感开始——雨气侵入肺腑，观者尚未举目，已被湖上的潮湿攫住。全诗由此展开，从肉身的浸润一路退向苍茫的水色，直至观者自身融散于景中。", "「湿雨沁心肺」，起句即以「沁」字立骨。湿雨落在皮肤上可言「润」，淋透衣衫可言「淋」，唯「沁」字一路渗入心肺深处，既是呼吸间湖畔水气灌入胸腔的实感，又将情绪的触动暗藏于生理体验之中。心属感，肺属息，二者并举，感与息同时被雨水穿透，身体便不再是风景的旁观者，而成了它的容器。", "「和风织锦纹」，「和」字取和缓、适中之意，兼有温度、力度与和顺，「风」便因此有了人情。「织」字将自然现象收入技艺的范畴——风成了织手，湖面成了绢帛，涟漪便是经纬交错的锦缎花纹。目光开始接管感知，画面由内而外渐渐展开。", "「岛洲横镜浦」，视线继续向远处推移。「浦」不取通称之「湖」，而取水滨小泊之义，将泸沽湖的阔大收束为一面可以端详的镜面，岛屿横卧其间，构图顿生静穆。「横」字见岛洲低伏之态，不耸不峙，与镜面的平阔相得，空间由此舒展为一幅横卷。", "「松影翠氤氲」，末句以其「影」言松，视线落在松下之「翠」，取玉石青碧之色，更见质感与冷冽。「氤氲」二字源出天地之气交合的古老意象，雾霭弥漫之中，松影与翠色已无清晰边界。至此，观者的目光也随之模糊——不再分辨物与影、色与气。", "回看全篇，感知的重心逐句外移：雨沁入肺腑，风织于水面，岛横于镜浦，松影散入烟岚。「沁」是向内渗透，「氤氲」是向外弥散，观者从被风景穿透，渐渐变为被风景吸纳。观景台的高处视角赋予后两句俯瞰全湖的空间纵深，而前两句的近身感受又使这纵深并非冷眼旁观——身体早已湿透，目光才随之远去。", "末句止于氤氲不散的雾色。观者与湖山之间最后一道轮廓，也被水气抹去。")
  let asset = "assets/poems/观湖/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "湖畔"
  let poem_lines = ("山脚连云镜，", "汀湾浪息甜。", "客游珠玉染，", "迁栈远葭蒹。")
  let context_note = "在泸沽湖畔浅滩，有感于湖边建筑后迁以保护环境而作。"
  let commentary = ("泸沽湖入诗，古来多写其空灵缥缈，此作却从生态退让的现实切口落笔，将山水清赏与人事抉择收于二十字之内，", "山脚、云影、镜湖——首句三个空间叠合为一，诗人的眼光从开篇便取了最大的纵深。此后三句层层收近，经汀湾、游客，最终落在湖边的一丛芦苇上，收于一个退让的动作。", "「山脚连云镜」起句先立起景象基座。「云镜」通过倒映之云气，写出湖面之平静与广阔。「连」字将山势、云影、湖光一气贯通，「脚」字点出衔接之处，暗示诗人视线所落。", "「汀湾浪息甜」转入近景特写。「汀湾」为浅滩弯处，正是下文中芦苇所在；浪息写出湖面波澜近岸时，轻柔扑面的气息，更以「甜」字，诉诸读者味觉，更显此刻恬静。", "「客游珠玉染」让突然入镜的游客，打破了前两句的平静怡然。「珠玉」形容湖光水色之质地，旅客游览至此，既为景色之美所感染，川流不息间，却也反向染污了珠玉。此处虽让两义并存，却也用语序提示，意在后者。", "「迁栈远葭蒹」作为末句，全诗前景至此才姗姗现身，题旨所归也相应揭开。「栈」为客栈旅舍，象征人类活动场所；「迁」而「远」之，所远者乃葭蒹——葭（jiā）和蒹（jiān）都是芦苇，只是前者初生，后者亦未长穗。此处虽然颠倒字序，亦借来了《诗经·秦风》中那承载千年水畔相思之意。此处的芦苇，不再是怅惘的寄托，而是需要被退让、被保全的湖岸生灵。「迁」字暗含主动，客栈后撤，芦荡得安，人的欲望之主动后撤，为自然的完整让出了空间。", "四句从全景收至近景，再从物象转入人事，最终落在一个「迁」的动作上。诗人未明言感慨，却以「甜」写出湖水被守护的值得，以「远」写出守护的代价与决心，为自然景象赋予了深刻的人文关怀。")
  let asset = "assets/poems/湖畔/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "泛舟"
  let poem_lines = ("云穹笼九岳，", "湖面澈如窗。", "风起银鱼跃，", "桨落酒窝双。")
  let context_note = "泛舟泸沽湖所作。"
  let commentary = ("泸沽湖上的舟行，诗人将之写成由远及近、由静入动的一组镜头。题为《泛舟》，正文却先不写舟，而从天、山、湖写起，将人的位置暂时放后；等到末句桨落，人的动作才轻轻现身。诗的调性是轻盈的，着落不在湖山辽阔，而在水面忽然生出的那一点温意。", "「云穹笼九岳」起笔相当高。「云穹」如盖，「笼」字读上声，取覆盖、笼罩之意，使群山不只是陈列在远处，而是被一整片天色收入同一空间。「九岳」不必实指九座山，重在推出山势环列、视野开阔的量感：无论向哪个方向望去，皆是山，皆是云。选用「岳」字，亦可见山势高耸入云，而非寻常山丘。", "「湖面澈如窗」把视线从高处收回水面。「澈」非「澄」，「澄」偏于静与清，「澈」还带着穿透之意；「如窗」二字里，湖面没有被比作反照外物的镜子，而被说成像可以望入的明净界面——湖水不只是清，而是有着可感的透。", "「风起银鱼跃」开始有声气与闪动。风过湖面，波纹腾跃，银光一片，像无数游鱼翻身；也可以是真的有鱼受风惊起，群跃而出。此句中妙在双关：银鱼是鱼，也是波光。「起」与「跃」一呼一应，使得方才还像窗一样静的湖，忽然活了。", "「桨落酒窝双」终于点出舟中之人。船「桨落」入水中，湖面相应生出两个漩涡，圆而浅，诗人竟用「酒窝双」来形容，恍惚间已经分不清那酒窝究竟是水中的波纹，还是舟中人甜美欢快的笑容。前句有风与光，此句有水与声。开阔的云穹、九岳、湖面、银鱼，至此皆收在一双小小的酒窝里，舟行之乐自不待言。", "从「笼」到「澈」，从「起」到「落」，动感渐出，镜头收束：天地山湖先铺开画卷，风与鱼呈现出动态，最后由一桨触水，引出水声与笑声；云穹这般恢宏的景象，最后化入一双酒窝。")
  let asset = "assets/poems/泛舟/illustration.png"
  let override = ("笼": "lǒng")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "途遇"
  let poem_lines = ("硕石滑坡车戛止，", "天晴时早众相嬉。", "千钧莫让夜将雨，", "悬壁滞停进退危。", "队序如安救援顺，", "清障重械万心旗。", "拓通险栈道旁护，", "出困何能报所贻。")
  let context_note = "泸沽湖返丽江途中遇山体滑坡被困得出所作。"
  let commentary = ("一辆行进中的车被硕石截停，《途遇》全诗八句从这极富冲击力的一刻写起，经危殆、秩序、救援，终落于感念。", "「硕石滑坡车戛止」，起句即带读者身临危境。「硕」字带厚重沉实之感——是自然巨物的分量，非人力可撼，比单纯量度大小多了一重质地。「戛止」尤为精切，戛者，硬物相触之声，止则骤然，声与势压缩于二字之中，金石迸裂之感扑面而来。", "「天晴时早众相嬉」，次句颇为反差，读者心情为之一缓。天色尚明，时辰尚早，众人嬉笑如常，仿佛滑坡不过是旅途的一段插曲。此句不写惊惶而写闲适，恰是未知危险时人最本真的状态——以轻托重，后文的千钧之压方有着落。", "「千钧莫让夜将雨」，笔势再次陡转。此处用千钧之典，渲染「千钧一发」之险，借其重量以喻处境之迫。读至「莫让」二字，方才明白，千钧也指代硕石，硕石兀自横立道中，不让车行，不以人意志为转移。「将」字不只是指出趋势，也从上句的天晴往前推进时间与天象，「夜」「雨」双重威胁汇合，湿坡再滑，黑暗侵袭，困局便不可收拾。", "「悬壁滞停进退危」，进一步收紧空间。车辆滞停、人群聚集之处并非安全无虞，悬壁在侧，前无去路，后亦险阻。「滞」较单用「停」字，多一层黏滞不得脱身之感，如陷泥淖。六字写尽地形之困，进退二字对举，危字收束，是全诗最逼仄的一刻。", "「队序如安救援顺」，转折在一「如」字。如安，非真安也，是众人知危而自持的镇定。此「如」标出克制之下的从容——明知险境仍不乱，方使救援得以展开。这是全诗的道德枢纽：人不是被动获救，而是以自身的克制参与了脱困。", "「清障重械万心旗」，救援场面以三组意象交叠而出：清障是动作，重械是器具，万心旗是精神。「旗」字将千万人的同心凝为一面可见的旗帜，是实写中的虚笔，令机械作业的现场升起一种仪式感。", "「拓通险栈道旁护」，「拓」取开辟道路之义，是以人力与机械在绝壁上重新劈开一条路。一「拓」字兼具力度与开创之意，颇见筚路蓝缕的艰辛。「险栈」暗合蜀道栈道之险，虽未具体描述如何狭窄、靠近悬崖，又有拦腰的凸起，却写出新通道仅可供人小心翼翼而过。道旁有人护持，既是安全措施，亦给人以守望的安心。此句拓通、守护，皆有救援者作为共同的隐形主语，引出末句主题。", "「出困何能报所贻」，末句以问收束。「贻」是古语中郑重的馈赠，将救援者的劳作、众人的秩序、那条重新拓开的路，统统升格为一份无法偿还的赠予。「何能报」三字在提出问题的同时亦是答案——有些恩义，记得本身便是回报。", "全诗自一声戛然始，经天晴之轻、千钧之重、悬壁之困，至队序井然、众心为旗，最终以拓路而出。其枢纽在第五句「如安」——真正化险为夷的，不止是重械清障，更是人在危境中维持的那一份从容。", "末尾留下的那个无法偿还的「贻」字，将整场历险化为对众人之赠的深念——既不渲染惊恐，亦不上升为豪壮，只让一字承担全部感念。")
  let asset = "assets/poems/途遇/illustration.png"
  let override = ("拓": "tuò")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "踏雪"
  let poem_lines = ("目迷云绝顶，", "仍上百折梯。", "攀陟风箱喘，", "冰川回首低。")
  let context_note = "带着高原反应，登顶玉龙雪山所作。"
  let commentary = ("《踏雪》这首五言在四句之间，鲜活写出诗人如何带着高原反应攀登玉龙雪山，气脉一路上行，至末句终而登顶俯瞰。", "「目迷云绝顶」，起句不言山高，先写目力之失。云萦绕着峰顶，此处若以云为主语，用「没」「隐」之类描述，遮蔽便只是外物所为；而「迷」落在观者自身，是眼睛在云中丧失了方向感，高原缺氧导致的眩晕已悄然渗入首句。「绝顶」二字，暗合杜甫「会当凌绝顶」之志，然杜诗是仰望中的期许，此刻身在半山，峰顶之绝已成切肤的眩目。", "「仍上百折梯」，一个「仍」字开启全诗精气神所在——目已迷、气已短，按常理当止步，诗人却以「仍」一笔逆转，将放弃的可能压在字底。「百折」表面写栈道回环，深处携「百折不挠」之意，从抽象意志化为脚下实体的梯级，虚实在一个词内完成交接。", "「攀陟风箱喘」，较常见的「攀登」而言，「陟」字声短力沉，多一层艰涩，恰合举步维艰之态。「风箱喘」三字尤为突兀：风箱是铁匠铺中的器物，粗粝、机械、带着金属的钝感，诗人将自己的肺腑比作被反复拉扯的风箱。此句聚焦身体内感，虽无一字及景，诗人在「百折梯」上一步步攀行的画面却历历在目，风箱之喻使此句成为全诗情志最烈之处。", "「冰川回首低」，登顶之后，诗人回首望去，冰川已在脚下。「回首」带着回望来路的感慨，「冰川」写出峰顶之凛冽寒风。此时的喜悦与征服感，尽在一个「低」字之中。方才仰望的一切——迷云、绝顶、百折梯——在这一俯瞰中被翻转，主客之间发生了一次无声的位移。", "四句从迷目写到俯瞰，身体始终是丈量高度的尺度：眼迷、步折、肺喘、首回。诗人不借助任何抒情词语，仅凭感官与动作的转移与变化，将一场躯体与海拔的角力写出了史诗感。末句的「低」，既是冰川在视野中的物理位置，也是全诗气脉由紧绷终而释放的落点。")
  let asset = "assets/poems/踏雪/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "月谷"
  let poem_lines = ("目游碧玺蓝，", "心淌雪山泉。", "卧石听潺瀑，", "意犹汀渚芊。")
  let context_note = "游蓝月谷所作。"
  let commentary = ("蓝月谷以雪山融水汇成碧潭，色若宝石，其蓝随深浅幽然变化。诗人从颜色的层次出发，一路渗入感官的深处，四官次第开放，人在谷中渐渐失去了自身的边界。", "「目游碧玺蓝」起句即奇。不言目「望」、目「见」，而言「游」——眼目如入水中，于色泽间自在游弋。一「游」字将观者与所观之界限消去，沉醉其中的观者已不在岸上，而在那片蓝中。「碧玺蓝」三字尤为考究，以碧玺这一矿石命名水色，可见并非寻常湖蓝，乃是有着如宝石切面般多层次的通透，唯以玺色方能传其质感。", "「心淌雪山泉」承转至内。「淌」本写液体缓缓流淌，此处却以心为主语——心如泉水般淌动，抑或雪山泉淌入心间，两读皆通。若用心「随」、心「系」，不过情感之追附；一「淌」字则令心具水性，与玉龙雪山之融泉同质同流，内外不复可分。", "「卧石听潺瀑」回到身体。「卧」将全身交付给溪石，全然沉浸而放松。卧而「听」之，亦借魏晋高士枕石漱流之意。瀑布令人联想到从飞流直下之壮阔，「潺瀑」二字却收着写作潺潺细响的层叠漫流，确合蓝月谷溪瀑之实。", "「意犹汀渚芊」收于心意。「汀渚」为古诗中水际沙洲之雅称，「芊」则承《楚辞》遗韵，状草木葳蕤柔茂，较之绿、茂更显绵软悠长。「意犹」乃心意仍驻留其间之谓：人或将行，而意仍在水洲草色之中，未曾抽离。", "四句依次以目、心、身、意入景，动词亦随之递变：游是目光之自在，淌是内心之流动，卧听是躯体之安适，犹是心意之驻留。由外而内，由动趋静，全诗不著一美字、一爱字，景致、情感全由感官之递进传出。蓝月谷独有之色，就此被由浅入深地印在读者意念之中。")
  let asset = "assets/poems/月谷/illustration.png"
  let override = (:)
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
#{
  let title = "回忆"
  let poem_lines = ("日游仙境景，", "夜酌少年事。", "方外尽酣欢，", "归来锁阁思。")
  let context_note = "出游结束后，回归日常工作仍未收心所作。"
  let commentary = ("《回忆》写于旅途归来之后，落笔却不在对行程的追述，而在归来之后、心神仍滞留远方的时刻。回望之下，所见所历皆经重新着色。", "「日游仙境景」先写百日游览山水。此处未细说「景」如何之美，径直将旅途景致唤作「仙境」，是归来后的追认：彼时身在其中或以为自然，此刻隔着日常回望，方感那片山水已不属于尘世所能轻易触及。", "「夜酌少年事」转入夜晚的共饮。用「酌」这个带有斟量、从容意味的动作，暗示酒是慢饮的，话是闲叙的，夜是长而不急的。所酌之事是「少年事」——不说往事、旧事，而说少年事，取的是那份轻快无羁的质地：旅途带人重新感受到的，不止是具体的过往，更是年少时的心境。", "「方外尽酣欢」将旅程整体体验加以收束。「方外」本是庄禅语汇，指世俗规矩之外的空间，较之「世外」更带一层主动出离的意味。这里说的既是与归后相比的方位，也给旅程轻轻定了性。「酣欢」二字兼得微醺的体温与舒展的欢愉，「尽」字则道出欢愉之尽情与无憾。归来后的怅然才不是对缺失的追索，而是对圆满的眷恋。", "「归来锁阁思」陡然令人从方外跌回阁楼之中。此处最可玩味者在一「锁」字。若换作困、守、居，皆是人对空间的被动关系；唯「锁」兼有两重指向——阁锁住了人的身体，而思却锁定在阁外的远方，一字之中，困与驰并存。「思」落在句末，未细言所思何事、何景、何人，指向着收不回的心，呼应着前三句铺开的回放。", "通观全篇所写回忆，前三句是内容，末句是状态；仙境与方外将旅途推向尘世之外，归来与锁阁将身体拽回日常之内，而「思」字悬于两界之间，念念不忘，悠悠回想。")
  let asset = "assets/poems/回忆/illustration.png"
  let override = ("少": "shào")
  render-poem(title, poem_lines, context_note, commentary, asset, override)
}
#pagebreak()
= 年谱
== 2011年春
#txt("《心意》《孤僧》《花泥》《相寻》")
== 2012年春
#txt("《年心》")
== 2013年春
#txt("《时机》")
== 2013年秋
#txt("《园校》")
== 2013年冬
#txt("《补天》")
== 2014年秋
#txt("《心旗》《屡战》《劳疾》《多艰》《还家》《喜临》《十月》")
== 2015年夏
#txt("《心屿》")
== 2015年冬
#txt("《断舍》《统帅》《心花》")
== 2016年春
#txt("《肩钧》《未竟》《低效》")
== 2016年夏
#txt("《雨澜》《整装》《衣悟》《启步》")
== 2016年秋
#txt("《战时》")
== 2016年冬
#txt("《疹热》")
== 2017年秋
#txt("《泳夜》《岩浆》")
== 2018年夏
#txt("《拭剑》")
== 2019年夏
#txt("《型势》《伙伴》《望空》")
== 2019年秋
#txt("《投融》")
== 2019年冬
#txt("《直前》《信使》《失学》《掌中》《尝假》《咏茶》")
== 2020年春
#txt("《将息》《齿轮》")
== 2020年秋
#txt("《闯潭》《咏酒》《鱼缸》《结游》《穿云》《盘山》《观湖》《湖畔》《泛舟》《途遇》《踏雪》《月谷》《回忆》")
== 2020年冬
#txt("《前行》《莫测》《自然》《羽决》《得遇》")
== 2021年春
#txt("《赴蹈》《难抉》《井观》《觉来》《出戏》《滋长》《遴选》")
== 2021年夏
#txt("《沉沦》《纵擒》")
== 2022年冬
#txt("《哧溜》")
== 2023年秋
#txt("《席散》")
== 2023年冬
#txt("《返初》")
== 2025年夏
#txt("《流迁》《穿越》")
== 未列入年谱
#txt("以下诗作缺少可确认写作时间，暂不列入年谱：夜会、心印")
#pagebreak()
= 代后记：在日常里写旧体诗的一点体会
#block(above: 0pt, below: 9pt)[#txt("旧体诗于我不是远离日常的古典陈设，而是一种压缩经验、整理心绪的方法。工作中的进退，家庭里的牵挂，旅途上的湖山，常常先成为一句可以反复咀嚼的话，再慢慢凝成四句或数联。")]
#block(above: 0pt, below: 9pt)[#txt("写得多了，越发觉得格律不是拘束，而像一副窄窄的骨架。它迫使情绪收束，也迫使含混的想法显出轮廓。字数有限，便不能事事铺陈，只能在取舍中留下最要紧的声气。")]
#block(above: 0pt, below: 9pt)[#txt("本书保留创作背景，也保留必要的拼音校注，是希望读者能同时看到诗句、当时处境与后来回看时的理解。若这些短诗还能在某个日常片刻里与人相遇，便已足够。")]
#pagebreak()
= LLM 辅助赏析写作说明
#block(above: 0pt, below: 9pt)[#txt("本书部分赏析由大语言模型辅助起草，再经作者审阅、修订或重写后收入。")]
#block(above: 0pt, below: 9pt)[#txt("收入标准以 frontmatter 的 `commentary-status` 为准：`human-revised` 与 `reference-quality` 可进入正文；`ai-review-only`、`iterated`、`unclear` 或缺少状态的文本不进入本书。")]
#block(above: 0pt, below: 9pt)[#txt("LLM 的作用主要是提供初稿结构、意象展开和可供反驳的解释线索。最终文本仍以作者确认后的版本为准。赏析不声称穷尽诗意，也不替代作者原始写作处境。")]
