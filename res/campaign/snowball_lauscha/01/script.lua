local TaskManager = require "TaskManager"
local missionutil = require "missionutil"

local function intro(data)
    local function complete(taskManager, task)
        task.setCompleted()
        taskManager:setMarker("talk_marker")
        missionutil.startTask(taskManager, "deliver_trees", data)
    end
    local strings = {
        name = {
            en = "Talk to the mayor",
            de = "Sprich mit dem Bürgermeister"
        },
        text1 = {
            en = "The landscape is deeply snowed and above the village lies the smell of spruce wood burnt in the fireplaces.",
            de = "Die Landschaft ist tief verschneit und über dem Dorf liegt der Geruch des in den Kaminen verbrannten Fichtenholzes."
        },
        text2 = {
            en = "We could first take a little walk in the forest ...",
            de = "Wir könnten erst einmal einen kleinen Spaziergang in dem Wald machen..."
        },
        text3 = {
            en = "When we're back, let's just drop by the mayor of [link=${lauscha}]Lauscha[/ link], he says there's something to do.",
            de = "Wenn wir wieder zurück sind sollten wir kurz beim Bürgermeister von [link=${lauscha}]Lauscha[/link] vorbeischauen, er sagt es gibt etwas zu tun."
        },
        hint = {
            en = "In this mission, there are no medals for extra speed or saving money. Relax, come to rest and enjoy the scenery ...",
            de = "In dieser Mission gibt es keine Medaillen für besondere Schnelligkeit oder Sparsamkeit. Entspannt euch, kommt zur Ruhe und genießt die Landschaft..."
        }
    }

    local info = {
        name = _(strings.name[data.lang]),
        paragraphs = {
            {text = _(strings.text1[data.lang])},
            {text = _(strings.text2[data.lang])},
            {text = _(strings.text3[data.lang]) % {lauscha = data.Lauscha_Town_id}},
            {text = _(strings.hint[data.lang]), type = "HINT"}
        },
        camera = {
            game.interface.getEntity(data.Lauscha_Town_id).position[1],
            game.interface.getEntity(data.Lauscha_Town_id).position[2],
            1000.0
        }
    }

    local task = missionutil.makeTask(info)
    task.init = function(taskManager, data)
        taskManager:setMarker("talk_marker", {entity = data.Lauscha_Town_id, type = "question"})
    end

    return task
end

local function deliverTrees(data)
    local function complete(taskManager, task)
        task.setCompleted()

        game.interface.upgradeConstruction(
            data.Steinach_Markt_id,
            "industry/christmas_market.con",
            {productionLevel = 0, prodState = 1}
        )
        game.interface.upgradeConstruction(
            data.Neuhaus_Markt_id,
            "industry/christmas_market.con",
            {productionLevel = 0, prodState = 1}
        )

        missionutil.startTask(taskManager, "connect_sand", data)
    end
    local strings = {
        name = {
            en = "Decorate the Christmas market",
            de = "Dekoriere den Weihnachtsmarkt"
        },
        greeting = {
            en = "Good morning!",
            de = "Guten Morgen!"
        },
        text1 = {
            en = "Good that you are there! The mayors of Steinach and Neuhaus asked me to help decorate their Christmas markets. Apart from the fact that they are both my cousins, the whole thing is of course in our interest, because if there is no Christmas spirit on the markets, our Christmas baubles sell badly.",
            de = "Gut dass du da bist! Die Bürgermeister von Steinach und Neuhaus haben mich gebeten ihnen beim Dekorieren ihrer Weihnachtsmärkte zu helfen. Abgesehen davon, dass sie beide meine Cousins sind, ist das ganze natürlich in unserem Interesse, denn wenn auf den Märkten keine Weihnachtsstimmung aufkommt verkaufen sich unsere Christbaumkugeln schlecht."
        },
        text2 = {
            en = "There are spruces everywhere, but as everyone knows, the most beautiful Christmas trees come from Lauscha. Maybe from Lichte ...",
            de = "Es gibt zwar überall Fichten, aber wie jeder weiß kommen die schönsten Weihnachtsbäume aus Lauscha. Vielleicht noch aus Lichte..."
        },
        text3 = {
            en = "Transport Christmas trees from the tree nursery in [link=${lauscha_bs}]Lauscha[/link] or [link=${lichte_bs}]Lichte[/ link] to the marketplaces in [link=${steinach_mp}]Steinach[/link] and [link=${neuhaus_mp}]Neuhaus[/link]",
            de = "Transportiere Weihnachtsbäume von der Baumschule in [link=${lauscha_bs}]Lauscha[/link] oder [link=${lichte_bs}]Lichte[/link] zu den Marktplätzen in [link=${steinach_mp}]Steinach[/link] und [link=${neuhaus_mp}]Neuhaus[/link]"
        },
        subtask1 = {
            en = "Transport Christmas trees to [link=${id}]Steinach[/link]",
            de = "Weihnachtsbäume nach [link=${id}]Steinach[/link] liefern"
        },
        subtask2 = {
            en = "Transport Christmas trees to [link=${id}]Neuhaus[/link]",
            de = "Weihnachtsbäume nach [link=${id}]Neuhaus[/link] liefern"
        }
    }

    local info = {
        name = _(strings.name[data.lang]),
        paragraphs = {
            {text = _(strings.greeting[data.lang])},
            {text = _(strings.text1[data.lang])},
            {text = _(strings.text2[data.lang])},
            {
                text = _(strings.text3[data.lang]) %
                    {
                        steinach_mp = data.Steinach_Markt_id,
                        neuhaus_mp = data.Neuhaus_Markt_id,
                        lichte_bs = data.Lichte_Baumschule_id,
                        lauscha_bs = data.Lauscha_Baumschule_id
                    },
                type = "TASK"
            }
        },
        subTasks = {}
    }

    info.subTasks[#info.subTasks + 1] = {
        name = _(strings.subtask1[data.lang]) % {id = data.Steinach_Markt_id}
    }

    info.subTasks[#info.subTasks + 1] = {
        name = _(strings.subtask2[data.lang]) % {id = data.Neuhaus_Markt_id}
    }

    local task = missionutil.makeTask(info)

    task.init = function(taskManager, data)
    end

    task.update =
        function(taskManager)
        if task.isCompleted() then
            return
        end

        local finished = 0
        local steinach_trees = 0

        steinach_trees = game.interface.getEntity(data.Steinach_Markt_Building_id).itemsConsumed["TREES"] or 0

        if steinach_trees >= data.Trees then
            finished = finished + 1
            if not task.isCompleted(1) then
                game.interface.upgradeConstruction(
                    data.Steinach_Markt_id,
                    "industry/christmas_market.con",
                    {productionLevel = 0, prodState = 1}
                )
                game.interface.book(data.DecorationAward)
                task.setCompleted(1)
            end
        else
            task.setProgressCount(steinach_trees, data.Trees, 1)
        end

        local neuhaus_trees = 0

        neuhaus_trees = game.interface.getEntity(data.Neuhaus_Markt_Building_id).itemsConsumed["TREES"] or 0

        if neuhaus_trees >= data.Trees then
            finished = finished + 1
            if not task.isCompleted(2) then
                game.interface.upgradeConstruction(
                    data.Neuhaus_Markt_id,
                    "industry/christmas_market.con",
                    {productionLevel = 0, prodState = 1}
                )
                game.interface.book(data.DecorationAward)
                task.setCompleted(2)
            end
        else
            task.setProgressCount(neuhaus_trees, data.Trees, 2)
        end

        task.setProgressCount(finished, 2)

        if finished == 2 then
            task.setCompleted()
            missionutil.startTask(taskManager, "connect_sand", data)
        end
    end

    task.setProgressNone()

    return task
end

local function connectSand(data)
    local sandpit_pos = {
        game.interface.getEntity(data.Steinheid_Sandgrube_id).position[1],
        (game.interface.getEntity(data.Steinheid_Sandgrube_id).position[2])
    }
    local factory_pos = {
        game.interface.getEntity(data.Lauscha_Glasfabrik_id).position[1],
        (game.interface.getEntity(data.Lauscha_Glasfabrik_id).position[2])
    }

    local function complete(taskManager, task)
        task.setCompleted()
        taskManager:setZone("sandpit")
        taskManager:setZone("factory")

        missionutil.startTask(taskManager, "talk_minerals", data)
    end

    local strings = {
        title = {
            en = "Glassmaking",
            de = "Glasherstellung"
        },
        name = {
            en = "Deliver quartz sand",
            de = "Quarzsand liefern"
        },
        text1 = {
            en = "Now that the Christmas markets are decorated, it's time to take care of the goods. Nothing sells better than the hand-blown baubles from Lauscha ... We should raise the business in a really big way!",
            de = "Jetzt, wo die Weihnachtsmärkte dekoriert sind, wird es Zeit sich um die Ware zu kümmern. Nichts verkauft sich besser als die Mundgeblasenen Christbaumkugeln aus Lauscha... Wir sollten das Geschäft im ganz großen Stil aufziehen!"
        },
        text2 = {
            en = "But we need more glass for that, and the main ingredient of glass is quartz sand. We obtain it from a sand pit at Steinheid, but so far it is being transported by donkey cart through the forest. Bernhard III, Duke of Sachsen-Meiningen, has provided 3,000,000 mark for the construction of a railway line!",
            de = "Dafür brauchen wir allerdings mehr Glas, und der Hauptbestandteil von Glas ist Quarzsand. Wir beziehen ihn von einer Sandgrube bei Steinheid, aber bisher wird er mit Eselskarren durch den Wald transportiert. Bernhard III, Herzog von Sachsen-Meiningen, hat uns 3.000.000 Mark für den Bau einer Bahnlinie zur Verfügung gestellt!"
        },
        task = {
            en = "Connect [link=${steinheid}][/link] and [link=${lauscha}][/link] with tracks",
            de = "Verbinde [link=${steinheid}][/link] und [link=${lauscha}][/link] mit Gleisen"
        },
        hint = {
            en = "There are good reasons why no one ever dared to build this railway line. Cost-effective routing could be a real challenge ...",
            de = "Es gibt gute Gründe, warum sich nie jemand daran gewagt hat diese Bahnlinie zu bauen. Eine kostengünstige Trassierung könnte zu einer echten Herausforderung werden..."
        }
    }

    local info = {
        title = _(strings.title[data.lang]),
        name = _(strings.name[data.lang]),
        paragraphs = {
            {text = _(strings.text1[data.lang])},
            {text = _(strings.text2[data.lang])},
            {
                type = "TASK",
                text = _(strings.task[data.lang]) %
                    {steinheid = data.Steinheid_Sandgrube_id, lauscha = data.Lauscha_Glasfabrik_id}
            },
            {type = "HINT", text = _(strings.hint[data.lang])}
        },
        camera = {sandpit_pos[1], sandpit_pos[2], 1000.0}
    }
    local task = missionutil.makeTask(info)

    task.init =
        function(taskManager, data)
        game.interface.book(3000000, false)

        taskManager:setZone(
            "sandpit",
            {polygon = missionutil.makeCircleZone(sandpit_pos, 400), draw = true, drawColor = missionutil.colors.GREEN}
        )
        taskManager:setZone(
            "factory",
            {polygon = missionutil.makeCircleZone(factory_pos, 400), draw = true, drawColor = missionutil.colors.GREEN}
        )
    end

    task.update =
        function(taskManager)
        if task.isCompleted() then
            return
        end

        if game.interface.findPath({pos = sandpit_pos, radius = 400}, {pos = factory_pos, radius = 400}, {TRAIN = true}) then
            complete(taskManager, task)

            taskManager:setZone("sandpit")
            taskManager:setZone("factory")

            missionutil.startTask(taskManager, "talk_minerals", data)
        end
    end

    return task
end

local function talkMinerals(data)
    local lager_pos = {
        game.interface.getEntity(data.Steinach_Lager_id).position[1],
        (game.interface.getEntity(data.Steinach_Lager_id).position[2])
    }

    local function complete(taskManager, task)
        task.setCompleted()
        taskManager:setMarker("drink_marker")
        missionutil.startTask(taskManager, "find_potashes", data)
    end

    local strings = {
        name = {
            en = "Obtain minerals",
            de = "Mineralien beschaffen"
        },
        text1 = {
            en = "Very good! Thanks to the railway line, bottlenecks in quartz sand will soon be a thing of the past!",
            de = "Sehr gut! Dank der Bahnlinie werden Engpässe beim Quarzsand bald der Vergangenheit angehören!"
        },
        text2 = {
            en = "Besides quartz sand, glass making requires some other minerals, namely soda as a flux and lime as a hardener.\n\nBoth are produced in Weißenbrunn. Fortunately, there's a middleman in Steinach, so we don't have to take all the way.",
            de = "Die Glasbläserei braucht neben Quarzsand aber noch weitere Mineralien, nämlich Soda als Flussmittel und Kalk als Härtemittel.\n\nBeide werden in Weißenbrunn produziert. Glücklicherweise gibt es in Steinach einen Zwischenhändler, sodass wir nicht den ganzen Weg auf uns nehmen müssen."
        },
        task = {
            en = "Drink a mulled wine with the middleman from the [link=${steinach}]mineral deposit Steinach[/link] to consolidate the business relationship.",
            de = "Trinke einen Glühwein mit dem Zwischenhändler vom [link=${steinach}]Mineralienlager Steinach[/link] um die Geschäftsbeziehungen zu festigen."
        }
    }

    local info = {
        name = _(strings.name[data.lang]),
        paragraphs = {
            {text = _(strings.text1[data.lang])},
            {text = _(strings.text2[data.lang])},
            {
                type = "TASK",
                text = _(strings.task[data.lang]) % {steinach = data.Steinach_Lager_id}
            }
        }
    }
    local task = missionutil.makeTask(info)

    task.init = function(taskManager, data)
        taskManager:setMarker("drink_marker", {entity = data.Steinach_Lager_id, type = "exclamation"})
    end

    task.update = function(taskManager)
        if task.isCompleted() then
            return
        end
    end

    return task
end

local function findPotashes(data)
    local function complete(taskManager, task)
        task.setCompleted()
        taskManager:setMarker("find_marker")
        missionutil.startTask(taskManager, "produce_potashes", data)
    end

    local strings = {
        name = {
            en = "Look for the potash works",
            de = "Suche das Aschenhaus auf"
        },
        text1 = {
            en = "A bird never flew on one wing - also not on five, so in the end you have drunk six cups of mulled wine. The only thing you can remember besides this number was the middlemans suggestion that soda alone might not be enough as a flux. We need potash to further lower the melting point of the sand.",
            de = "Auf einem Bein, da steht man schlecht - auf fünfen scheinbar auch, denn am Ende hast du sechs Becher Glühwein getrunken. Das einzige woran du dich, neben dieser Zahl, noch erinnern kannst war der Hinweis des Händlers, dass Soda als Flussmittel allein wahrscheinlich nicht ausreicht. Wir brauchen Pottasche um den Schmelzpunkt des Sands weiter zu senken."
        },
        text2 = {
            en = "Potash is produced in a potash works. I think I know where to find one...",
            de = "Pottasche wird in sogenannten Aschenhäusern gewonnen. Ich glaube ich weiß wo eins steht..."
        },
        task = {
            en = "Look for the [link=${aschenhaus}]potash works in Igelshieb[/link].",
            de = "Suche das [link=${aschenhaus}]Aschenhaus in Igelshieb[/link] auf."
        }
    }

    local info = {
        name = _(strings.name[data.lang]),
        paragraphs = {
            {text = _(strings.text1[data.lang])},
            {text = _(strings.text2[data.lang])},
            {
                type = "TASK",
                text = _(strings.task[data.lang]) % {aschenhaus = data.Aschenhaus_id}
            }
        }
    }
    local task = missionutil.makeTask(info)

    task.init = function(taskManager, data)
        taskManager:setMarker("find_marker", {entity = data.Aschenhaus_id, type = "question"})
    end

    task.update = function(taskManager)
        if task.isCompleted() then
            return
        end
    end

    return task
end

local function producePotashes(data)
    local function complete(taskManager, task)
        task.setCompleted()
        missionutil.startTask(taskManager, "produce_baubles", data)
    end

    local strings = {
        name = {
            en = "Produce potashes",
            de = "Produziere Pottasche"
        },
        greeting = {
            en = "Hello!",
            de = "Hallo!"
        },
        text1 = {
            en = "It's true, we can produce potash here, but we need a huge amount of wood for that. In case you manage to supply us with enough wood, we can provide you with potash",
            de = "Es stimmt, wir können hier Pottasche produzieren, allerdings brauchen wir dafür ungeheure Mengen Holz! Wenn ihr es schafft uns mit ausreichend Holz zu beliefern, können wir euch auch genug Pottasche bereitstellen."
        },
        text2 = {
            en = "Wood should not be hard to find, after all we are in the high Thuringian Slate Mountains, and if we have one thing in abundance, then it is definitely wood.",
            de = "Holz sollte nicht schwer zu finden sein, schließlich sind wir hier im hohen Thüringer Schiefergebirge, und wenn wir eines im Überfluss haben, dann ist es definitiv Holz."
        },
        task = {
            en = "Supply the [link=${aschenhaus}]potash works in Igelshieb[/link] with wood to produce potash.",
            de = "Beliefere das [link=${aschenhaus}]Aschenhaus Igelshieb[/link] mit Holz um Pottasche zu produzieren."
        }
    }

    local info = {
        name = _(strings.name[data.lang]),
        paragraphs = {
            {text = _(strings.greeting[data.lang])},
            {text = _(strings.text1[data.lang])},
            {text = _(strings.text2[data.lang])},
            {
                text = _(strings.task[data.lang]) %
                    {
                        aschenhaus = data.Aschenhaus_id
                    },
                type = "TASK"
            }
        },
        subTasks = {}
    }

    local task = missionutil.makeTask(info)

    task.init = function(taskManager, data)
    end

    task.update = function(taskManager)
        if task.isCompleted() then
            return
        end

        local produced = game.interface.getEntity(data.Aschenhaus_Building_id).itemsProduced["POTASH"] or 0

        if produced > 0 then
            task.setCompleted()
            missionutil.startTask(taskManager, "produce_baubles", data)
        end
    end

    task.setProgressNone()

    return task
end

local function produceBaubles(data)
    local function complete(taskManager, task)
        task.setCompleted()
    end

    local strings = {
        name = {
            en = "Produce baubles",
            de = "Produziere Christbaumkugeln"
        },
        text1 = {
            en = "We should now have all ingredients together to produce glass. When to deliver them to the glass factory, we should be able to produce baubles. Then, we can transport them to the christmas markets of Steinach and Neuhaus.",
            de = "Wir sollten jetzt alle Rohstoffe beisammen haben. Wenn wir alle zur Glasbläserei transportieren, sollten wir in der Lage sein Christbaumkugeln zu produzieren. Anschließend können wir sie auf den Weihnachtsmärkten von Neuhaus und Steinach verkaufen."
        },
        task1 = {
            en = "Deliver quartz sand, minerals, potash and logs to the [link=${fabrik}]Lauscha glass factory[/link] to produce baubles.",
            de = "Beliefere die [link=${fabrik}]Glasbläserei Lauscha[/link] mit Quarzsand, Mineralien, Pottasche und Brennholz um Christbaumkugeln zu produzieren."
        },
        task2 = {
            en = "Deliver the baubles to the christmas markets of [link=${steinach}]Steinach[/link] and [link=${neuhaus}]Neuhaus[/link].",
            de = "Beliefere die Weihnachtsmärkte in [link=${steinach}]Steinach[/link] und [link=${neuhaus}]Neuhaus[/link] mit Christbaumkugeln."
        },
        taskproduce = {
            en = "Produce baubles",
            de = "Christbaumkugeln produzieren"
        },
        taskdeliver1 = {
            en = "Deliver baubles to [link=${id}]Steinach[/link]",
            de = "Christbaumkugeln nach [link=${id}]Steinach[/link] liefern"
        },
        taskdeliver2 = {
            en = "Deliver baubles to [link=${id}]Neuhaus[/link]",
            de = "Christbaumkugeln nach [link=${id}]Neuhaus[/link] liefern"
        },
    }

    local info = {
        name = _(strings.name[data.lang]),
        paragraphs = {
            {text = _(strings.text1[data.lang])},
            {
                text = _(strings.task1[data.lang]) % {fabrik = data.Lauscha_Glasfabrik_id},
                type = "TASK"
            },
            {
                text = _(strings.task2[data.lang]) %
                    {
                        steinach = data.Steinach_Markt_id,
                        neuhaus = data.Neuhaus_Markt_id
                    },
                type = "TASK"
            }
        },
        subTasks = {}
    }

    info.subTasks[#info.subTasks + 1] = {
        name = _(strings.taskproduce[data.lang])
    }

    info.subTasks[#info.subTasks + 1] = {
        name = _(strings.taskdeliver1[data.lang]) % {id = data.Steinach_Markt_id}
    }

    info.subTasks[#info.subTasks + 1] = {
        name = _(strings.taskdeliver2[data.lang]) % {id = data.Neuhaus_Markt_id}
    }

    local task = missionutil.makeTask(info)

    task.init = function(taskManager, data)
    end

    task.update = function(taskManager)
        if task.isCompleted() then
            return
        end

        local finished = 0
        local produced = game.interface.getEntity(data.Lauscha_Glasfabrik_Building_id).itemsProduced["BAUBLES"] or 0

        if produced > 0 then
            finished = finished + 1
            if not task.isCompleted(1) then
                task.setCompleted(1)
            end
        end

        local steinach_baubles = 0

        steinach_baubles = game.interface.getEntity(data.Steinach_Markt_Building_id).itemsConsumed["BAUBLES"] or 0

        if steinach_baubles >= data.Baubles then
            finished = finished + 1
            if not task.isCompleted(2) then
                task.setCompleted(2)
            end
        else
            task.setProgressCount(steinach_baubles, data.Baubles, 2)
        end

        local neuhaus_baubles = 0

        neuhaus_baubles = game.interface.getEntity(data.Neuhaus_Markt_Building_id).itemsConsumed["BAUBLES"] or 0
        local neuhaus = game.interface.getEntity(data.Neuhaus_Markt_Building_id)

        if neuhaus_baubles >= data.Baubles then
            finished = finished + 1
            if not task.isCompleted(3) then
                task.setCompleted(3)
            end
        else
            task.setProgressCount(neuhaus_baubles, data.Baubles, 3)
        end

        task.setProgressCount(finished, 3)

        if finished == 3 then
            task.setCompleted()
        end
    end

    task.setProgressNone()

    return task
end

function data()
    local tm = TaskManager.new()

    local allConstructions = game.interface.getEntities({pos = {0, 0}, radius = 90000000}, {type = "CONSTRUCTION"})

    local data = {
        Trees = 60,
        Baubles = 244,
        DecorationAward = 1000000,
        Forests = {}
    }

    local translated = _("Hervorragend!")
    if (translated == "Hervorragend!") then
        data.lang = "de"
    else
        data.lang = "en"
    end

    for i = 1, #allConstructions do
        c = allConstructions[i]
        cData = game.interface.getEntity(c)
		
        if (cData.fileName == "industry/forest.con") then
            data.Forests[#data.Forests + 1] = c
        end

        if (cData.name == "Neuhaus am Rennweg Weihnachtsmarkt #2") then
            data.Neuhaus_Markt_id = c
            data.Neuhaus_Markt_Building_id = cData.simBuildings[1]
        end
        if (cData.name == "Steinach Weihnachtsmarkt #2") then
            data.Steinach_Markt_id = c
            data.Steinach_Markt_Building_id = cData.simBuildings[1]
        end
        if (cData.name == "Lichte Baumschule") then
            data.Lichte_Baumschule_id = c
            data.Lichte_Baumschule_Building_id = cData.simBuildings[1]
        end
        if (cData.name == "Lauscha Baumschule") then
            data.Lauscha_Baumschule_id = c
            data.Lauscha_Baumschule_Building_id = cData.simBuildings[1]
        end
        if (cData.name == "Steinheid Sandgrube") then
            data.Steinheid_Sandgrube_id = c
            data.Steinheid_Sandgrube_Building_id = cData.simBuildings[1]
        end
        if (cData.name == "Lauscha Glasbläserei") then
            data.Lauscha_Glasfabrik_id = c
            data.Lauscha_Glasfabrik_Building_id = cData.simBuildings[1]
        end
        if (cData.name == "Steinach Mineralienlager #2") then
            data.Steinach_Lager_id = c
            data.Steinach_Lager_Building_id = cData.simBuildings[1]
        end
        if (cData.name == "Igelshieb Aschenhaus") then
            data.Aschenhaus_id = c
            data.Aschenhaus_Building_id = cData.simBuildings[1]
        end
    end

    local allTowns = game.interface.getTowns()
    for i = 1, #allTowns do
        c = allTowns[i]
        cData = game.interface.getEntity(c)

        if (cData.name == "Lauscha") then
            data.Lauscha_Town_id = c
        end
        if (cData.name == "Neuhaus am Rennweg") then
            data.Neuhaus_Town_id = c
        end
        if (cData.name == "Lichte") then
            data.Lichte_Town_id = c
        end
        if (cData.name == "Steinach") then
            data.Steinach_Town_id = c
        end
    end

    local assets = game.interface.getEntities({pos = {0, 0}, radius = 90000000}, {type = "ASSET_GROUP"})
    for i = 1, #assets do
        c = assets[i]
        cData = game.interface.getEntity(c)
    end

    tm:register("intro", intro, data)
    tm:register("deliver_trees", deliverTrees, data)
    tm:register("connect_sand", connectSand, data)
    tm:register("talk_minerals", talkMinerals, data)
    tm:register("find_potashes", findPotashes, data)
    tm:register("produce_potashes", producePotashes, data)
    tm:register("produce_baubles", produceBaubles, data)

    local mission = missionutil.makeMissionInterface(tm)
   

    mission.onInit(
        function()
           
            game.interface.setPlayer (data.Lauscha_Baumschule_id, nil)
            game.interface.setPlayer (data.Lichte_Baumschule_id, nil)
            game.interface.setPlayer (data.Steinach_Markt_id, nil)
            game.interface.setPlayer (data.Neuhaus_Markt_id, nil)
            game.interface.setPlayer (data.Steinach_Lager_id, nil)
            game.interface.setPlayer (data.Steinheid_Sandgrube_id, nil)
            game.interface.setPlayer (data.Aschenhaus_id, nil)
            game.interface.setPlayer (data.Lauscha_Glasfabrik_id, nil)

            for i = 1, #data.Forests do
                game.interface.setPlayer (data.Forests[i], nil)
            end

            game.interface.clearJournal()
            game.interface.book(10000000, false)

            tm:add("intro", data)
        end
    )

    mission.onMarkerEvent(
        function(params)
            if (params.key == "talk_marker") then
                tm:setMarker("talk_marker")
                tm:getById("intro").setCompleted()
                tm:add("deliver_trees", data)
            end
            if params.key == "drink_marker" then
                tm:setMarker("drink_marker")
                tm:getById("talk_minerals").setCompleted()
                tm:add("find_potashes", data)
            end
            if params.key == "find_marker" then
                tm:setMarker("find_marker")
                tm:getById("find_potashes").setCompleted()
                tm:add("produce_potashes", data)
            end
        end
    )

    mission.onUpdate(
        function()
        end
    )

    return mission
end
