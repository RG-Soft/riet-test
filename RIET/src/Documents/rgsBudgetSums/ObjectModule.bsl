
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.rgsBudgetsums.Записывать = Истина;
	Движения.rgsBudgetsums.Очистить();
	
	Движения.InternationalAndDomesticFactCosts.Записывать = Истина;
	Движения.InternationalAndDomesticFactCosts.Очистить();
	
	Движения.MobillizationBudget.Записывать = Истина;
	Движения.MobillizationBudget.Очистить();
	//{ RGS AArsentev S-I-0003157 14.06.2017 15:48:45
	Если BudgetType = Справочники.rgsBudgetType.MS Тогда
		Запрос = новый запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	rgsBudgetSums.Ссылка
		|ИЗ
		|	Документ.rgsBudgetSums КАК rgsBudgetSums
		|ГДЕ
		|	rgsBudgetSums.Дата МЕЖДУ &Дата1 И &Дата2
		|	И НЕ rgsBudgetSums.ПометкаУдаления
		|	И rgsBudgetSums.BudgetType = &BudgetType
		|	И rgsBudgetSums.Ссылка <> &Ссылка";
		Запрос.УстановитьПараметр("Дата1",НачалоМесяца(Дата));
		Запрос.УстановитьПараметр("Дата2",КонецМесяца(Дата));
		Запрос.УстановитьПараметр("BudgetType", Справочники.rgsBudgetType.MS);
		Запрос.УстановитьПараметр("Ссылка",Ссылка);
		Результат = Запрос.Выполнить();
		Если  Результат.Пустой() Тогда		
			Для Каждого Элемент Из Budget_MS Цикл
				ДвижениеBudgetSums = Движения.rgsBudgetSums.Добавить();
				ДвижениеBudgetSums.Период = НачалоМесяца(Дата);
				ДвижениеBudgetSums.BudgetType = BudgetType;
				ДвижениеBudgetSums.Geomarket = Элемент.Geomarket;
				ДвижениеBudgetSums.SubGeomarket = Элемент.SubGeomarket;
				ДвижениеBudgetSums.Segment = Элемент.Segment;
				ДвижениеBudgetSums.SubSegment = Элемент.SubSegment;	
				ДвижениеBudgetSums.TypeInternationalDomestic = Элемент.InternationalDomestic;
				ДвижениеBudgetSums.Sum = Элемент.Summa;
			КонецЦикла;	
		Иначе
			Отказ = Истина;
			Message = New UserMessage();
			Message.Text = "В этом месяце уже был проведен документ бюджетирования с типом M&S";
			Message.Message();	
		КонецЕсли;
	ИначеЕсли BudgetType = Справочники.rgsBudgetType.TandM Тогда
	//} RGS AArsentev S-I-0003157 14.06.2017 15:48:45
		Запрос = новый запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	rgsBudgetSums.Ссылка
		|ИЗ
		|	Документ.rgsBudgetSums КАК rgsBudgetSums
		|ГДЕ
		|	rgsBudgetSums.Дата МЕЖДУ &Дата1 И &Дата2
		|	И НЕ rgsBudgetSums.ПометкаУдаления
		|	И rgsBudgetSums.BudgetType = &BudgetType
		|	И rgsBudgetSums.Ссылка <> &Ссылка";
		Запрос.УстановитьПараметр("Дата1",НачалоКвартала(Дата));
		Запрос.УстановитьПараметр("Дата2",КонецКвартала(Дата));
		Запрос.УстановитьПараметр("BudgetType",BudgetType);
		Запрос.УстановитьПараметр("Ссылка",Ссылка);
		Результат = Запрос.Выполнить().Выгрузить();
		Если Результат.Количество() = 0 тогда							   
			
			ТаблицаДвижений = ПолучитьТаблицуДвижений();
			
			Если ТаблицаДвижений <> Неопределено Тогда				
				Для каждого Строка из ТаблицаДвижений цикл				
					ДвижениеBudgetSums = Движения.rgsBudgetSums.Добавить();
					ДвижениеBudgetSums.Период = Строка.Дата;
					ДвижениеBudgetSums.BudgetType = BudgetType;
					ДвижениеBudgetSums.Geomarket = Строка.Geom;
					ДвижениеBudgetSums.SubGeomarket = Строка.SubGem;
					ДвижениеBudgetSums.Segment = Строка.Segm;
					ДвижениеBudgetSums.SubSegment = Строка.SubSegm;	
					ДвижениеBudgetSums.TypeInternationalDomestic = Строка.In_Dom;
					ДвижениеBudgetSums.Sum = Строка.RevenueSum * Строка.Percent / 3;					
					Если Строка.ManualEntrySum <> 0 Тогда					
						ДвижениеFactCosts = Движения.InternationalAndDomesticFactCosts.Добавить();
						ДвижениеFactCosts.Регистратор = Ссылка;
						ДвижениеFactCosts.Период = Строка.Дата;
						ДвижениеFactCosts.Geomarket = Строка.Geom;
						ДвижениеFactCosts.SubGeomarket = Строка.SubGem;
						ДвижениеFactCosts.Segment = Строка.Segm;
						ДвижениеFactCosts.SubSegment = Строка.SubSegm;
						ДвижениеFactCosts.CostsType = Перечисления.FactCostsTypes.ManualEntry;
						ДвижениеFactCosts.DomesticInternational = Строка.In_Dom;
						ДвижениеFactCosts.Sum = Строка.ManualEntrySum * Строка.Percent / 3;	
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;		
		Иначе
			Отказ = Истина;
			Message = New UserMessage();
			Message.Text = "В этом квартале уже был проведен документ бюджетирования";
			Message.Message();
		КонецЕсли;
		
	ИначеЕсли BudgetType = Справочники.rgsBudgetType.SummerMobillization ИЛИ BudgetType = Справочники.rgsBudgetType.WinterMobillization Тогда
		
		Для Каждого Элемент Из Mobillization Цикл
			ДвижениеBudgetSums = Движения.MobillizationBudget.Добавить();
			ПроверитьПериодМобиллизации(Элемент.Period, Отказ);
			ДвижениеBudgetSums.Период = НачалоМесяца(Элемент.Period);
			Если BudgetType = Справочники.rgsBudgetType.SummerMobillization Тогда
				MobillizationType = Перечисления.SummerWinter.SummerNavigation;
			ИначеЕсли BudgetType = Справочники.rgsBudgetType.WinterMobillization Тогда
				MobillizationType = Перечисления.SummerWinter.WinterMobilization;
			КонецЕсли;
			ДвижениеBudgetSums.MobillizationType = MobillizationType;
			ДвижениеBudgetSums.Project = Элемент.Project;
			ДвижениеBudgetSums.AU = Элемент.AU;
			ДвижениеBudgetSums.ServiceProvider = Элемент.ServiceProvider;
			ДвижениеBudgetSums.TypeOfTransport = Элемент.TypeOfTransport;
			
			ДвижениеBudgetSums.Sum = Элемент.Summa;
			ДвижениеBudgetSums.TnKm = Элемент.TnKm;
			ДвижениеBudgetSums.Weight = Элемент.Weight;
			
			ДвижениеBudgetSums.City = Элемент.City;
			ДвижениеBudgetSums.Region = Элемент.Region;
			ДвижениеBudgetSums.Geomarket = Элемент.Geomarket;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуДвижений()
	
	ТаблицаДвижений = Неопределено;

	Отказ = Ложь;
	ДатаНачала = НачалоКвартала(Дата);
	Месяц = 0;
	
	ТЗ_InDom = новый ТаблицаЗначений;
	ТЗ_InDom.Колонки.Добавить("In_Dom");
	ТЗ_InDom.Колонки.Добавить("Percent");
		
	Пока Месяц <> 3 цикл
		
		ЗапросПроценты = новый Запрос;
		ЗапросПроценты.Текст = "ВЫБРАТЬ
		|	rgsBudgetPercentageСрезПоследних.BudgetItem,
		|	rgsBudgetPercentageСрезПоследних.Percent,
		|	rgsBudgetPercentageСрезПоследних.Период,
		|	rgsBudgetPercentageСрезПоследних.BudgetItem.GroupLevel КАК GroupLevel,
		|	rgsBudgetPercentageСрезПоследних.BudgetType,
		|	rgsBudgetPercentageСрезПоследних.BudgetItem.SubLevel КАК SubLevel,
		|	rgsBudgetPercentageСрезПоследних.BudgetItem.BudgetPercentType КАК BudgetPercentType
		|ИЗ
		|	РегистрСведений.rgsBudgetPercentage.СрезПоследних(&Дата, BudgetType = &BudgetType) КАК rgsBudgetPercentageСрезПоследних";
		ЗапросПроценты.УстановитьПараметр("Дата",ДобавитьМесяц(ДатаНачала, Месяц));
		ЗапросПроценты.УстановитьПараметр("BudgetType",BudgetType);
		РезультатПроценты = ЗапросПроценты.Выполнить().Выгрузить();
		
		
		Для Каждого ТекСтрокаBudget Из Budget Цикл
			ТЗ_InDom.Очистить();
			Отбор = новый Структура;
			Отбор.Вставить("GroupLevel", ТекСтрокаBudget.Geomarket);
			Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.Sub_Geomarket);
			РезультатПроценты_Геомаркет = РезультатПроценты.Скопировать(Отбор); 
			
			Отбор = новый Структура;
			Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.InternationalDomestic);
			Отбор.Вставить("GroupLevel", ТекСтрокаBudget.Geomarket);
			
			РезультатПроценты_IntDom = РезультатПроценты.Скопировать(Отбор);
			
			
			Если РезультатПроценты_IntDom.Количество() > 0 тогда
				Для каждого Строка_IntDom из РезультатПроценты_IntDom цикл						
					
					СтрокаInDom = ТЗ_InDom.Добавить();
					СтрокаInDom.In_Dom = Строка_IntDom.SubLevel;
					СтрокаInDom.Percent = Строка_IntDom.Percent / 100;
					
				КонецЦикла;
			Иначе							
				Message = New UserMessage();
				Message.Text = "Нет процентов International / Domestic по " + ТекСтрокаBudget.Geomarket + " на дату "+ Формат(ДобавитьМесяц(ДатаНачала, Месяц), "ДФ=dd.MM.yyyy");
				Message.Message();
				Отказ = истина;	
				продолжить
			КонецЕсли;
			
			Если РезультатПроценты_Геомаркет.Количество() > 0 и РезультатПроценты_IntDom.Количество() > 0 тогда
				ТЗ_с_Геомаркетами = ТЗ_InDom.Скопировать();
				ТЗ_с_Геомаркетами.Очистить();
				ТЗ_с_Геомаркетами.Колонки.Добавить("Geom");
				ТЗ_с_Геомаркетами.Колонки.Добавить("SubGem");
				Для каждого Строка_Geomarket из РезультатПроценты_Геомаркет цикл						
					
					Для каждого Строка_ТЗ_InDom из ТЗ_InDom цикл
						Строка_ТЗ_с_Геомаркетами = ТЗ_с_Геомаркетами.Добавить();
						Строка_ТЗ_с_Геомаркетами.In_Dom = Строка_ТЗ_InDom.In_Dom;
						Строка_ТЗ_с_Геомаркетами.Geom = Строка_Geomarket.GroupLevel;
						Строка_ТЗ_с_Геомаркетами.SubGem = Строка_Geomarket.SubLevel;
						Строка_ТЗ_с_Геомаркетами.Percent = Строка_ТЗ_InDom.Percent * Строка_Geomarket.Percent / 100;
					КонецЦикла;
					
				КонецЦикла;
				SubGeomarkets = ТЗ_с_Геомаркетами.ВыгрузитьКолонку("SubGem");	
			Иначе
				Message = New UserMessage();
				Message.Text = "Нет процентов по Субгеомаркету, Геомаркета - " + ТекСтрокаBudget.Geomarket + " на дату "+ Формат(ДобавитьМесяц(ДатаНачала, Месяц), "ДФ=dd.MM.yyyy");
				Message.Message();
				Отказ = истина;
				продолжить
			КонецЕсли;
			
			ЗапросСабы = новый запрос;
			ЗапросСабы.Текст = "ВЫБРАТЬ
			|	rgsBudgetPercentageСрезПоследних.Percent,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.SubLevel КАК Segment,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.GroupLevel КАК GroupLevel
			|ИЗ
			|	РегистрСведений.rgsBudgetPercentage.СрезПоследних(
			|			&Дата,
			|			BudgetType = &BudgetType
			|				И BudgetItem.BudgetPercentType = &BudgetPercentType
			|				И BudgetItem.GroupLevel В (&СабГеомаркеты)) КАК rgsBudgetPercentageСрезПоследних";
			ЗапросСабы.УстановитьПараметр("Дата",ДобавитьМесяц(ДатаНачала, Месяц));
			ЗапросСабы.УстановитьПараметр("BudgetType",BudgetType);
			ЗапросСабы.УстановитьПараметр("СабГеомаркеты",SubGeomarkets);
			ЗапросСабы.УстановитьПараметр("BudgetPercentType",Перечисления.rgsBudgetPercentTypes.SubGeomarket_Segment);
			
			РезультатПроцентыСубГео_Сегмент = ЗапросСабы.Выполнить().Выгрузить(); 
			
			Если РезультатПроцентыСубГео_Сегмент.Количество() > 0 тогда
				ТЗ_с_Сегментами = ТЗ_с_Геомаркетами.Скопировать();
				ТЗ_с_Сегментами.Очистить();
				ТЗ_с_Сегментами.Колонки.Добавить("Segm");
				ТЗ_с_Сегментами.Колонки.Добавить("SubGeo_Segm");
				
				
				
				Для каждого Строка_ТЗ_с_Геомаркетами из ТЗ_с_Геомаркетами цикл
					Отбор = Новый Структура;
					Отбор.Вставить("GroupLevel", Строка_ТЗ_с_Геомаркетами.SubGem);
					ПроцентыСубГео = РезультатПроцентыСубГео_Сегмент.Скопировать(Отбор);
					
					Для каждого Строка_ПроцентыСубГео_Сегмент из ПроцентыСубГео цикл
						Если ПроцентыСубГео.Количество() > 0 Тогда				
							Строка_ТЗ_с_Сегментами = ТЗ_с_Сегментами.Добавить();
							Строка_ТЗ_с_Сегментами.In_Dom = Строка_ТЗ_с_Геомаркетами.In_Dom;
							Строка_ТЗ_с_Сегментами.Geom = Строка_ТЗ_с_Геомаркетами.Geom;
							Строка_ТЗ_с_Сегментами.SubGem = Строка_ТЗ_с_Геомаркетами.SubGem;
							Строка_ТЗ_с_Сегментами.Segm = Строка_ПроцентыСубГео_Сегмент.Segment;
							
							Строка_ТЗ_с_Сегментами.SubGeo_Segm = Строка_ПроцентыСубГео_Сегмент.BudgetItem;
							Строка_ТЗ_с_Сегментами.Percent = Строка_ТЗ_с_Геомаркетами.Percent * Строка_ПроцентыСубГео_Сегмент.Percent / 100;
						Иначе
							Message = New UserMessage();
							Message.Text = "Нет процента для СубГеомаркета / Сегмента" + Строка_ТЗ_с_Геомаркетами.SubGem;
							Message.Message();
							Отказ = истина;
							Прервать
						КонецЕсли;
					КонецЦикла;
					
				КонецЦикла;
				СубГео_Сегмент = РезультатПроцентыСубГео_Сегмент.ВыгрузитьКолонку("BudgetItem");
				
			Иначе
				Message = New UserMessage();
				Message.Text = "Нет Сегментов, соответствующих СабГеомаркетам на дату "+ Формат(ДобавитьМесяц(ДатаНачала, Месяц), "ДФ=dd.MM.yyyy");
				Message.Message();
				Отказ = истина;
				продолжить
			КонецЕсли;
			
			
			ЗапросСабСегмент = Новый запрос;
			ЗапросСабСегмент.Текст = "ВЫБРАТЬ
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.Ссылка КАК Ссылка,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.SubLevel КАК SubLevel,
			|	rgsBudgetPercentageСрезПоследних.Percent,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.GroupLevel КАК GroupLevel
			|ИЗ
			|	РегистрСведений.rgsBudgetPercentage.СрезПоследних(
			|			&Дата,
			|			BudgetType = &BudgetType
			|				И BudgetItem.BudgetPercentType = &BudgetPercentType
			|				И BudgetItem.GroupLevel В (&GroupLevel)) КАК rgsBudgetPercentageСрезПоследних";
			ЗапросСабСегмент.УстановитьПараметр("Дата",ДобавитьМесяц(ДатаНачала, Месяц));
			ЗапросСабСегмент.УстановитьПараметр("BudgetType",BudgetType);
			ЗапросСабСегмент.УстановитьПараметр("BudgetPercentType",Перечисления.rgsBudgetPercentTypes.Sub_Segment);
			ЗапросСабСегмент.УстановитьПараметр("GroupLevel",СубГео_Сегмент);
			РезультатПроценты_СабСегмент = ЗапросСабСегмент.Выполнить().Выгрузить(); 
			
			Если РезультатПроценты_СабСегмент.Количество() > 0 тогда
				
				ТЗ_с_СабСегментами = ТЗ_с_Сегментами.Скопировать();
				ТЗ_с_СабСегментами.Очистить();
				ТЗ_с_СабСегментами.Колонки.Добавить("SubSegm");
				ТЗ_с_СабСегментами.Колонки.Добавить("Дата");
				ТЗ_с_СабСегментами.Колонки.Добавить("RevenueSum");
				ТЗ_с_СабСегментами.Колонки.Добавить("ManualEntrySum");
				Для каждого Строка_ТЗ_с_Сегментами из ТЗ_с_Сегментами цикл
					
					Отбор = новый структура;         
					Отбор.Вставить("GroupLevel", Строка_ТЗ_с_Сегментами.SubGeo_Segm); 
					РезультатПроценты_СабСегменты = РезультатПроценты_СабСегмент.Скопировать(Отбор);
					
					Для каждого Строка_SubSegment из РезультатПроценты_СабСегменты цикл
						Строка_ТЗ_с_СабСегментами = ТЗ_с_СабСегментами.Добавить();
						Строка_ТЗ_с_СабСегментами.In_Dom = Строка_ТЗ_с_Сегментами.In_Dom;
						Строка_ТЗ_с_СабСегментами.Geom = Строка_ТЗ_с_Сегментами.Geom;
						Строка_ТЗ_с_СабСегментами.SubGem = Строка_ТЗ_с_Сегментами.SubGem;
						Строка_ТЗ_с_СабСегментами.Segm = Строка_ТЗ_с_Сегментами.Segm;
						Строка_ТЗ_с_СабСегментами.SubSegm = Строка_SubSegment.SubLevel;
						Строка_ТЗ_с_СабСегментами.Percent = Строка_ТЗ_с_Сегментами.Percent * Строка_SubSegment.Percent / 100;
						Строка_ТЗ_с_СабСегментами.Дата = ДобавитьМесяц(ДатаНачала, Месяц);
						Строка_ТЗ_с_СабСегментами.RevenueSum = ТекСтрокаBudget.RevenueSum;
						Строка_ТЗ_с_СабСегментами.ManualEntrySum = ТекСтрокаBudget.ManualEntrySum;					
					КонецЦикла;	
					
				КонецЦикла;
				
			Иначе
				
				Message = New UserMessage();
				Message.Text = "Нет процентов по СабСегментам на дату "+ Формат(ДобавитьМесяц(ДатаНачала, Месяц), "ДФ=dd.MM.yyyy");
				Message.Message();
				Отказ = истина;
				продолжить
			КонецЕсли;
			
			Если Месяц = 0 Тогда
				
				Если ТаблицаДвижений = Неопределено Тогда 
					ТаблицаДвижений = Новый ТаблицаЗначений;
					ТаблицаДвижений = ТЗ_с_СабСегментами.СкопироватьКолонки();
				КонецЕсли;
			
				ДополнитьТаблицу(ТЗ_с_СабСегментами,ТаблицаДвижений)
				
			Иначе
				
				ДополнитьТаблицу(ТЗ_с_СабСегментами,ТаблицаДвижений)
				
			КонецЕсли;				
			
		КонецЦикла;			
		
		Месяц = Месяц + 1;
	КонецЦикла;
	
	Если НЕ Отказ Тогда
		Возврат ТаблицаДвижений
	Иначе
		Возврат ""
	КонецЕсли;
	
КонецФункции

&НаСервере
Процедура ДополнитьТаблицу(ТаблицаИсточник, ТаблицаПриемник) Экспорт 

Для Каждого СтрокаТаблицыИсточник Из ТаблицаИсточник Цикл 

ЗаполнитьЗначенияСвойств(ТаблицаПриемник.Добавить(), СтрокаТаблицыИсточник); 

КонецЦикла; 

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если BudgetType = Справочники.rgsBudgetType.MS ИЛИ BudgetType = Справочники.rgsBudgetType.WinterMobillization ИЛИ BudgetType = Справочники.rgsBudgetType.SummerMobillization Тогда
		Дата = НачалоМесяца(Дата);
	Иначе
		Дата = НачалоКвартала(Дата);
	КонецЕсли;
	
	ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ModificationDate = ТекущаяДата();
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение ИЛИ Проведен Тогда
		ПроверитьРеквизитыПриПроведении(Отказ);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьПериодМобиллизации(Период, Отказ)
	
	Если Не ЗначениеЗаполнено(Период) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("В табличной части документа не указан пустой период!");
		Отказ = Истина;
	КонецЕсли;
	
	Если BudgetType = Справочники.rgsBudgetType.WinterMobillization Тогда
		
		Если Месяц(Период) = 12 ИЛИ Месяц(Период) >= 1 И Месяц(Период) <= 4 Тогда
		Иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Период " + Период + " не относится к 'Winter mobillization'");
			Отказ = Истина;
		КонецЕсли;
		
	ИначеЕсли BudgetType = Справочники.rgsBudgetType.SummerMobillization Тогда
		
		Если Месяц(Период) >= 6 И Месяц(Период) <= 10 Тогда
		Иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Период " + Период + " не относится к 'Summer mobillization'");
			Отказ = Истина;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьРеквизитыПриПроведении(Отказ)
	
	Для Каждого СтрокаТЧ Из Mobillization Цикл
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.AU) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "В строке " + СтрокаТЧ.НомерСтроки + " мобилизации: не заполнено поле ""AU / центр затрат""!";
				иначе
					ТекстОшибки = "In line " + СтрокаТЧ.НомерСтроки + " of mobillization: ""AU"" is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
				ЭтотОбъект, "Mobillization[" + (СтрокаТЧ.НомерСтроки - 1) + "].AU", , Отказ);
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Project) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "В строке " + СтрокаТЧ.НомерСтроки + " мобилизации: не заполнено поле ""Project / проект""!";
				иначе
					ТекстОшибки = "In line " + СтрокаТЧ.НомерСтроки + " of mobillization: ""Project"" is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
				ЭтотОбъект, "Mobillization[" + (СтрокаТЧ.НомерСтроки - 1) + "].Project", , Отказ);
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.ServiceProvider) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "В строке " + СтрокаТЧ.НомерСтроки + " мобилизации: не заполнено поле ""ServiceProvider / Поставщик услуг""!";
				иначе
					ТекстОшибки = "In line " + СтрокаТЧ.НомерСтроки + " of mobillization: ""ServiceProvider"" is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
				ЭтотОбъект, "Mobillization[" + (СтрокаТЧ.НомерСтроки - 1) + "].ServiceProvider", , Отказ);
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Geomarket) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "В строке " + СтрокаТЧ.НомерСтроки + " мобилизации: не заполнено поле ""Geomarket / геомаркет""!";
				иначе
					ТекстОшибки = "In line " + СтрокаТЧ.НомерСтроки + " of mobillization: ""Geomarket"" is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
				ЭтотОбъект, "Mobillization[" + (СтрокаТЧ.НомерСтроки - 1) + "].Geomarket", , Отказ);
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.City) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "В строке " + СтрокаТЧ.НомерСтроки + " мобилизации: не заполнено поле ""City / город""!";
				иначе
					ТекстОшибки = "In line " + СтрокаТЧ.НомерСтроки + " of mobillization: ""City"" is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
				ЭтотОбъект, "Mobillization[" + (СтрокаТЧ.НомерСтроки - 1) + "].City", , Отказ);
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Region) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "В строке " + СтрокаТЧ.НомерСтроки + " мобилизации: не заполнено поле ""Region / регион""!";
				иначе
					ТекстОшибки = "In line " + СтрокаТЧ.НомерСтроки + " of mobillization: ""Region"" is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
				ЭтотОбъект, "Mobillization[" + (СтрокаТЧ.НомерСтроки - 1) + "].Region", , Отказ);
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Period) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "В строке " + СтрокаТЧ.НомерСтроки + " мобилизации: не заполнено поле ""Period / период""!";
				иначе
					ТекстОшибки = "In line " + СтрокаТЧ.НомерСтроки + " of mobillization: ""Period"" is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
				ЭтотОбъект, "Mobillization[" + (СтрокаТЧ.НомерСтроки - 1) + "].Period", , Отказ);
				
			КонецЕсли;
			
	КонецЦикла;
	
КонецПроцедуры