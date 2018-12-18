
&НаКлиенте
Процедура ИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ДиалогВыбора = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбора.Фильтр     = "Файл Excel (*.xlsx)|*.xlsx";
	ДиалогВыбора.Расширение = "xlsx";
	Если ДиалогВыбора.Выбрать() Тогда
		//ПапкаСКартинками = СтрЗаменить(ДиалогВыбора.ПолноеИмяФайла, ".xls", ".files")  + "\";
		//КаталогНаДиске = Новый Файл(ПапкаСКартинками);
		//Если Не КаталогНаДиске.Существует() Тогда
		//	Предупреждение("Создайте папку с картинками! Откройте файл и сохраните копию в формате ""Веб-страница(*.htm;*.html)""");
		//	Возврат;
		//КонецЕсли;
		Объект.ИмяФайла = ДиалогВыбора.ПолноеИмяФайла;
		Объект.Revenue.Очистить();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТЧТоварыКартинкаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ДиалогВыбора = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбора.Фильтр     = "Файл Excel (*.png)|*.png";
	ДиалогВыбора.Расширение = "png";
	Если ДиалогВыбора.Выбрать() Тогда
		Элементы.ТЧТовары.ТекущиеДанные.Картинка = ДиалогВыбора.ПолноеИмяФайла;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПрочитатьИзФайла(Команда)
	
	Если Не ЗначениеЗаполнено(Объект.ИмяФайла)  Тогда
		Вопрос("Выберите файл!", РежимДиалогаВопрос.ОК);
		Возврат;
	КонецЕсли;
	
	
	
	
	ФайлВыгрузки = Объект.ИмяФайла;
	
	// подключимся к файлу
	Попытка
		ОбъектExcel = Новый COMОбъект("Excel.Application");    
		ОбъектExcel.Visible=0;
		ОбъектExcel.WorkBooks.Open(СокрЛП(ФайлВыгрузки));
		Листы = ОбъектExcel.Sheets;
		Лист1 = ОбъектExcel.WorkSheets(Листы.Item(1).Name);
		Лист1 = Лист1.UsedRange;
		Лист2 = ОбъектExcel.WorkSheets(Листы.Item(2).Name);
		Лист2 = Лист2.UsedRange;		
		Лист3 = ОбъектExcel.WorkSheets(Листы.Item(3).Name);
		Лист3 = Лист3.UsedRange;		
		Лист4 = ОбъектExcel.WorkSheets(Листы.Item(4).Name);
		Лист4 = Лист4.UsedRange;	
		Лист5 = ОбъектExcel.WorkSheets(Листы.Item(5).Name);
		Лист5 = Лист5.UsedRange;		
		Лист6 = ОбъектExcel.WorkSheets(Листы.Item(6).Name);
		Лист6 = Лист6.UsedRange;
		
	Исключение
		Сообщить("Ошибка открытия файла ! " + строка(ОписаниеОшибки()));
		Возврат;
	КонецПопытки;
	
	ПервыйЛист(Лист1);
	ВторойЛист(Лист2);
	ТретийЛист(Лист3);
	ЧетвертыйЛист(Лист4);
	ПятыйЛист(Лист5);
	ШестойЛист(Лист6);
	
	ОбъектExcel.quit();
	
КонецПроцедуры


&НаКлиенте
Процедура ЗаписатьВсеВБазу(Команда)
	
	//Если Не ЗначениеЗаполнено(Объект.Группа) или Не ЗначениеЗаполнено(Объект.ЕдиницаИзмерения)
	//	или Не ЗначениеЗаполнено(Объект.ВидНоменклатуры) или Не ЗначениеЗаполнено(Объект.СтавкаНДС) или Не ЗначениеЗаполнено(Объект.ТЧТовары) Тогда
	//	Предупреждение("Заполните пустые поля!");
	//	Возврат;
	//КонецЕсли;	
	ПоискИОбработкаНоменклатуры();
	
	
	
	
КонецПроцедуры


&НаСервере
Процедура ПоискИОбработкаНоменклатуры()
	
	//Для Каждого Стр Из Объект.ТЧТовары Цикл
	//	Номенклатура = Справочники.Номенклатура.НайтиПоРеквизиту("Артикул",Стр.Артикул);
	//	НоменклатураКод = Справочники.Номенклатура.НайтиПоКоду(Стр.Код);
	//	Если НЕ ЗначениеЗаполнено(Номенклатура) или НЕ ЗначениеЗаполнено(НоменклатураКод) Тогда
	//		Номенклатура = Справочники.Номенклатура.СоздатьЭлемент();	
	//		Номенклатура.Код = Стр.Код;
	//		Номенклатура.Артикул = Стр.Артикул;
	//		Номенклатура.Родитель = Объект.Группа;
	//		Номенклатура.ВидНоменклатуры = Объект.ВидНоменклатуры;
	//		Номенклатура.ЕдиницаИзмерения = Объект.ЕдиницаИзмерения;
	//		Номенклатура.Наименование = Стр.Наименование;
	//		Номенклатура.НаименованиеПолное = Стр.Наименование;
	//		Номенклатура.СтавкаНДС = Объект.СтавкаНДС;
	//		Номенклатура.Качество = Перечисления.ГрадацииКачества.Новый;
	//		Номенклатура.Записать();
	//		Сообщить("Создана номенклатура: " + Номенклатура);
	//	Иначе
	//		Номенклатура = Номенклатура.ПолучитьОбъект();
	//	КонецЕсли;
	//	ЗаполнитьКартинку(Номенклатура, Стр.Картинка);
	//	Номенклатура.Записать();
	//КонецЦикла;
	//Сообщить("Загрузка успешно завершена");
	
	Для Каждого Стр Из Объект.ТЧТовары Цикл
		
		Док = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
		Док.ВидОперации = Перечисления.ВидыОперацийРеализацияТоваров.Услуги;
		Док.Дата = Дата(Стр.ДатаОтправки);
		Док.Организация =  Объект.Организация;
		Док.Контрагент = Объект.Контрагент;
		
		СтрокаТЧ = Док.Услуги.Добавить();
		СтрокаТЧ.Номенклатура = Справочники.Номенклатура.НайтиПоНаименованию("Ремонтные услуги");
		СтрокаТЧ.Содержание = "Перевозка груза " + Стр.Груз + " в количестве " +Стр.Вес+  " тонн со станции " + Стр.СтанцияОтправления + " до станции " + Стр.СтанцияНазначения;
		СтрокаТЧ.СтавкаНДС = перечисления.СтавкиНДС.НДС18;
		СтрокаТч.Сумма = Стр.СтоимостьБезНДС;
		СтрокаТч.СуммаНДС = Стр.НДС;
		СтрокаТч.Количество = Стр.Вес;
		Док.Записать();	
	КонецЦикла;
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	//Объект.СтавкаНДС = НайтиРеквизит("НДС");
	//ВидНоменкл = НайтиРеквизит("Товар");
	//Если  ЗначениеЗаполнено(ВидНоменкл) Тогда
	//	Объект.ВидНоменклатуры = ВидНоменкл;
	//КонецЕсли;
	//ЕдХр = НайтиРеквизит("Шт");
	//Если  ЗначениеЗаполнено(ЕдХр) Тогда
	//	Объект.ЕдиницаИзмерения = ЕдХр;		
	//КонецЕсли;
	
КонецПроцедуры

&Насервере
Функция  НайтиРеквизит(Реквизит)
	Если Реквизит = "Товар" Тогда
		Возврат Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Товар");
	ИначеЕсли Реквизит = "Шт"  Тогда
		Возврат Справочники.ЕдиницыИзмерения.НайтиПоНаименованию("Шт");
	ИначеЕсли Реквизит = "НДС" Тогда 		
		Возврат Перечисления.СтавкиНДС.НДС18;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ПервыйЛист(Лист)
	
	КоличествоИспользуемыхКолонок = Лист.Columns.Count();
	КоличествоИспользуемыхСтрок = Лист.Rows.Count();
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество колонок в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество строк в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	
	НомерКартинки = 0;
	
	Объект.Revenue.Очистить();
	
	
	Для Строка = 2 по КоличествоИспользуемыхСтрок Цикл
		ОбработкаПрерыванияПользователя();
		Если Лист.Cells(Строка, 1).Value = "" Тогда
			Прервать
		КонецЕсли;
		СтрокаRevenue = Объект.Revenue.Добавить();
		СтрокаRevenue.Geomarket = СокрЛП(Лист.Cells(Строка, 1).Value);
		СтрокаRevenue.Percent = СокрЛП(Лист.Cells(Строка, 2).Value);
	КонецЦикла;	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ВторойЛист(Лист)
	
	КоличествоИспользуемыхКолонок = Лист.Columns.Count();
	КоличествоИспользуемыхСтрок = Лист.Rows.Count();
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество колонок в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество строк в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	
	Объект.Geomarket_Segment.Очистить();
	
	
	Для Строка = 2 по КоличествоИспользуемыхСтрок Цикл
		ОбработкаПрерыванияПользователя();
		Если Лист.Cells(Строка, 1).Value = "" Тогда
			Прервать
		КонецЕсли;
		СтрокаGeomarket_Segment = Объект.Geomarket_Segment.Добавить();
		СтрокаGeomarket_Segment.Geomarket = СокрЛП(Лист.Cells(Строка, 1).Value);
		СтрокаGeomarket_Segment.Segment = СокрЛП(Лист.Cells(Строка, 2).Value);
		СтрокаGeomarket_Segment.Percent = СокрЛП(Лист.Cells(Строка, 3).Value);
	КонецЦикла;	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ТретийЛист(Лист)
	
	КоличествоИспользуемыхКолонок = Лист.Columns.Count();
	КоличествоИспользуемыхСтрок = Лист.Rows.Count();
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество колонок в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество строк в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	
	Объект.Int_Dom.Очистить();
	
	
	Для Строка = 2 по КоличествоИспользуемыхСтрок Цикл
		ОбработкаПрерыванияПользователя();
		Если Лист.Cells(Строка, 1).Value = "" Тогда
			Прервать
		КонецЕсли;
		СтрокаInt_Dom = Объект.Int_Dom.Добавить();
		СтрокаInt_Dom.Geomarket = СокрЛП(Лист.Cells(Строка, 1).Value);
		СтрокаInt_Dom.Int_Dom = СокрЛП(Лист.Cells(Строка, 2).Value);
		СтрокаInt_Dom.Percent = СокрЛП(Лист.Cells(Строка, 3).Value);
	КонецЦикла;	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ЧетвертыйЛист(Лист)
	
	КоличествоИспользуемыхКолонок = Лист.Columns.Count();
	КоличествоИспользуемыхСтрок = Лист.Rows.Count();
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество колонок в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество строк в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	
	Объект.SubGeomarket.Очистить();
	
	
	Для Строка = 2 по КоличествоИспользуемыхСтрок Цикл
		ОбработкаПрерыванияПользователя();
		Если Лист.Cells(Строка, 1).Value = "" Тогда
			Прервать
		КонецЕсли;
		СтрокаSubGeomarket = Объект.SubGeomarket.Добавить();
		СтрокаSubGeomarket.Geomarket = СокрЛП(Лист.Cells(Строка, 1).Value);
		СтрокаSubGeomarket.SubGeomarket = СокрЛП(Лист.Cells(Строка, 2).Value);
		СтрокаSubGeomarket.Percent = СокрЛП(Лист.Cells(Строка, 3).Value);
	КонецЦикла;	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ПятыйЛист(Лист)
	
	КоличествоИспользуемыхКолонок = Лист.Columns.Count();
	КоличествоИспользуемыхСтрок = Лист.Rows.Count();
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество колонок в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество строк в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	
	Объект.SubGeomarket_Segment.Очистить();
	
	
	Для Строка = 2 по КоличествоИспользуемыхСтрок Цикл
		ОбработкаПрерыванияПользователя();
		Если Лист.Cells(Строка, 1).Value = "" Тогда
			Прервать
		КонецЕсли;
		СтрокаSubGeomarket_Segment = Объект.SubGeomarket_Segment.Добавить();
		СтрокаSubGeomarket_Segment.SubGeomarket = СокрЛП(Лист.Cells(Строка, 1).Value);
		СтрокаSubGeomarket_Segment.Segment = СокрЛП(Лист.Cells(Строка, 2).Value);
		СтрокаSubGeomarket_Segment.Percent = СокрЛП(Лист.Cells(Строка, 3).Value);
	КонецЦикла;	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ШестойЛист(Лист)
	
	КоличествоИспользуемыхКолонок = Лист.Columns.Count();
	КоличествоИспользуемыхСтрок = Лист.Rows.Count();
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество колонок в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	Если КоличествоИспользуемыхКолонок = 0 Тогда
		Сообщить("Количество строк в файле должно быть <> 0");
		Возврат;
	КонецЕсли;
	
	Объект.SubSegment.Очистить();
	
	
	Для Строка = 2 по КоличествоИспользуемыхСтрок Цикл
		ОбработкаПрерыванияПользователя();
		Если Лист.Cells(Строка, 1).Value = "" Тогда
			Прервать
		КонецЕсли;
		СтрокаSubSegment = Объект.SubSegment.Добавить();
		СтрокаSubSegment.SubGeomarket = СокрЛП(Лист.Cells(Строка, 1).Value);
		СтрокаSubSegment.Segment = СокрЛП(Лист.Cells(Строка, 2).Value);
		СтрокаSubSegment.SubSegment = СокрЛП(Лист.Cells(Строка, 3).Value);
		СтрокаSubSegment.Percent = СокрЛП(Лист.Cells(Строка, 4).Value);
	КонецЦикла;	
	
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьВБазуНаСервере()
	
	ДокументПроцентов = Документы.rgsBudgetPercentage.СоздатьДокумент();
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	rgsBudgetItem.Ссылка,
	|	rgsBudgetItem.BudgetPercentType,
	|	rgsBudgetItem.GroupLevel,
	|	rgsBudgetItem.SubLevel
	|ИЗ
	|	Справочник.rgsBudgetItem КАК rgsBudgetItem";
	Результат = Запрос.Выполнить().Выгрузить();
	
	Для каждого Строка из Объект.Revenue цикл
				
		Отбор = новый Структура;
		Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.RevenueProcent);
		Отбор.Вставить("GroupLevel", Справочники.GeoMarkets.НайтиПоКоду(Строка.Geomarket));
		
		РезультатRevenue = Результат.Скопировать(Отбор);
		
		СтрокаRevenue = ДокументПроцентов.RevenueProcent.Добавить();
		
		Если РезультатRevenue.Количество() > 0 тогда
			
			СтрокаRevenue.BudgetItem = РезультатRevenue[0].Ссылка;
			
		Иначе
			
			Revenue = Справочники.rgsBudgetItem.СоздатьЭлемент();
			Revenue.BudgetPercentType = Перечисления.rgsBudgetPercentTypes.RevenueProcent;
			Revenue.GroupLevel = Справочники.GeoMarkets.НайтиПоКоду(Строка.Geomarket);
			Revenue.Наименование = "" + Перечисления.rgsBudgetPercentTypes.RevenueProcent + "/" +  Строка.Geomarket;
			Revenue.Записать();
			
			СтрокаRevenue.BudgetItem = Revenue.Ссылка;
			
		КонецЕсли;
		
		СтрокаRevenue.Percent = Строка.Percent * 100;
		
	КонецЦикла;	
	
	
	Для каждого Строка из Объект.Geomarket_Segment цикл
		
		Если не ЗначениеЗаполнено(Справочники.Сегменты.НайтиПоКоду(Строка.Segment)) тогда
			Message = New UserMessage();
			Message.Text = "Не нашел сегмент " + Строка.Segment + " Пропустил строку для ТЧ Geomarket_Segment";
			Message.Message();
			продолжить
		КонецЕсли;

		
		
		Отбор = новый Структура;
		Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.Geomarket_Segment);
		Отбор.Вставить("GroupLevel", Справочники.GeoMarkets.НайтиПоКоду(Строка.Geomarket));
		Отбор.Вставить("SubLevel", Справочники.Сегменты.НайтиПоКоду(Строка.Segment));
		
		РезультатGeomarket_Segment = Результат.Скопировать(Отбор);
		
		СтрокаGeomarket_Segment = ДокументПроцентов.GeomarketSegment.Добавить();
		
		Если РезультатGeomarket_Segment.Количество() > 0 тогда
			
			СтрокаGeomarket_Segment.BudgetItem = РезультатGeomarket_Segment[0].Ссылка;			
			
		Иначе
			
			GeomarketSegment = Справочники.rgsBudgetItem.СоздатьЭлемент();
			GeomarketSegment.BudgetPercentType = Перечисления.rgsBudgetPercentTypes.Geomarket_Segment;
			GeomarketSegment.GroupLevel = Справочники.GeoMarkets.НайтиПоКоду(Строка.Geomarket);
			GeomarketSegment.SubLevel = Справочники.Сегменты.НайтиПоКоду(Строка.Segment);
			GeomarketSegment.Наименование = "" + Перечисления.rgsBudgetPercentTypes.Geomarket_Segment + "/" +  Строка.Geomarket + "/" + Строка.Segment;
			GeomarketSegment.Записать();
			
			СтрокаGeomarket_Segment.BudgetItem = GeomarketSegment.Ссылка;
			
		КонецЕсли;
		
		СтрокаGeomarket_Segment.Percent = Строка.Percent * 100 ;
		
	КонецЦикла;
	
	
	Для каждого Строка из Объект.Int_Dom цикл
		
		Отбор = новый Структура;
		Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.InternationalDomestic);
		Отбор.Вставить("GroupLevel", Справочники.GeoMarkets.НайтиПоКоду(Строка.Geomarket));
		Если Строка.Int_Dom = "Domestic" Тогда 
			Отбор.Вставить("SubLevel", Перечисления.DomesticInternational.Domestic);
		Иначе
			Отбор.Вставить("SubLevel", Перечисления.DomesticInternational.International);
		КонецЕсли;
		
		РезультатInt_Dom = Результат.Скопировать(Отбор);
		
		СтрокаInt_Dom = ДокументПроцентов.InternationalDomestic.Добавить();
		
		Если РезультатInt_Dom.Количество() > 0 тогда
			
			СтрокаInt_Dom.BudgetItem = РезультатInt_Dom[0].Ссылка;
			СтрокаInt_Dom.Group_Level = РезультатInt_Dom[0].GroupLevel
			
		Иначе
			
			IntDom = Справочники.rgsBudgetItem.СоздатьЭлемент();
			IntDom.BudgetPercentType = Перечисления.rgsBudgetPercentTypes.InternationalDomestic;
			IntDom.GroupLevel = Справочники.GeoMarkets.НайтиПоКоду(Строка.Geomarket);
			Если Строка.Int_Dom = "Domestic" Тогда 
				IntDom.SubLevel = Перечисления.DomesticInternational.Domestic;
			Иначе
				IntDom.SubLevel = Перечисления.DomesticInternational.International;
			КонецЕсли;
			IntDom.Наименование = "" + Перечисления.rgsBudgetPercentTypes.InternationalDomestic + "/" +  Строка.Geomarket + "/" + Перечисления.DomesticInternational.Domestic;
			IntDom.Записать();
			
			СтрокаInt_Dom.BudgetItem = IntDom.Ссылка;
			СтрокаInt_Dom.Group_Level = IntDom.Ссылка.GroupLevel; 
			
		КонецЕсли;
		
		СтрокаInt_Dom.Percent = Строка.Percent ;
		
	КонецЦикла;
	
	
	
	Для каждого Строка из Объект.SubGeomarket цикл
		
		Отбор = новый Структура;
		Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.Sub_Geomarket);
		Отбор.Вставить("GroupLevel", Справочники.GeoMarkets.НайтиПоКоду(Строка.Geomarket));
		Отбор.Вставить("SubLevel", Справочники.GeoMarkets.НайтиПоКоду(Строка.SubGeomarket));
		
		РезультатSubGeomarket = Результат.Скопировать(Отбор);
		
		СтрокаSub_Geomarket = ДокументПроцентов.Sub_Geomarket.Добавить();
		
		Если РезультатSubGeomarket.Количество() > 0 тогда
			
			СтрокаSub_Geomarket.BudgetItem = РезультатSubGeomarket[0].Ссылка;			
			СтрокаSub_Geomarket.Group_Level = РезультатSubGeomarket[0].GroupLevel; 
			
		Иначе
			
			SubGeomarket = Справочники.rgsBudgetItem.СоздатьЭлемент();
			SubGeomarket.BudgetPercentType = Перечисления.rgsBudgetPercentTypes.Sub_Geomarket;
			SubGeomarket.GroupLevel = Справочники.GeoMarkets.НайтиПоКоду(Строка.Geomarket);
			SubGeomarket.SubLevel = Справочники.GeoMarkets.НайтиПоКоду(Строка.SubGeomarket);
			SubGeomarket.Наименование = "" + Перечисления.rgsBudgetPercentTypes.Sub_Geomarket + "/" +  Строка.Geomarket + "/" + Строка.SubGeomarket;
			SubGeomarket.Записать();
			
			
			СтрокаSub_Geomarket.BudgetItem = SubGeomarket.Ссылка;
			СтрокаSub_Geomarket.Group_Level = SubGeomarket.Ссылка.GroupLevel;
			
			
		КонецЕсли;
		
		СтрокаSub_Geomarket.Percent = Строка.Percent;
		
	КонецЦикла;
	
	
	
	Для каждого Строка из Объект.SubGeomarket_Segment цикл
		
		Если не ЗначениеЗаполнено(Справочники.Сегменты.НайтиПоКоду(Строка.Segment)) тогда
			Message = New UserMessage();
			Message.Text = "Не нашел сегмент " + Строка.Segment + " Пропустил строку для ТЧ SubGeomarket_Segment";
			Message.Message();
			продолжить
		КонецЕсли;

		
		
		Отбор = новый Структура;
		Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.SubGeomarket_Segment);
		Отбор.Вставить("GroupLevel", Справочники.GeoMarkets.НайтиПоКоду(Строка.SubGeomarket));
		Отбор.Вставить("SubLevel", Справочники.Сегменты.НайтиПоКоду(Строка.Segment));
		
		РезультатSubGeomarket_Segment = Результат.Скопировать(Отбор);
		
		СтрокаSubGeomarket_Segment = ДокументПроцентов.SubGeo_Segment.Добавить();
		
		Если РезультатSubGeomarket_Segment.Количество() > 0 тогда
			
			СтрокаSubGeomarket_Segment.BudgetItem = РезультатSubGeomarket_Segment[0].Ссылка;			 
			
		Иначе
			
			SubGeomarketSegment = Справочники.rgsBudgetItem.СоздатьЭлемент();
			SubGeomarketSegment.BudgetPercentType = Перечисления.rgsBudgetPercentTypes.SubGeomarket_Segment;
			SubGeomarketSegment.GroupLevel = Справочники.GeoMarkets.НайтиПоКоду(Строка.SubGeomarket);
			SubGeomarketSegment.SubLevel = Справочники.Сегменты.НайтиПоКоду(Строка.Segment);
			SubGeomarketSegment.Наименование = "" + Перечисления.rgsBudgetPercentTypes.SubGeomarket_Segment + "/" +  Строка.SubGeomarket + "/" + Строка.Segment;
			SubGeomarketSegment.Записать();
			
			СтрокаSubGeomarket_Segment.BudgetItem = SubGeomarketSegment.Ссылка;			
			
		КонецЕсли;
		
		СтрокаSubGeomarket_Segment.Percent = Строка.Percent;
		
	КонецЦикла;
	
	
	
	Для каждого Строка из Объект.SubSegment цикл
		
		Если не ЗначениеЗаполнено(Справочники.Сегменты.НайтиПоКоду(Строка.Segment)) тогда
			Message = New UserMessage();
			Message.Text = "Не нашел сегмент " + Строка.Segment + " Пропустил строку для ТЧ SubGeomarket_Segment";
			Message.Message();
			продолжить
		КонецЕсли;
		
		Если не ЗначениеЗаполнено(Справочники.Сегменты.НайтиПоКоду(Строка.Segment)) тогда
			Message = New UserMessage();
			Message.Text = "Не нашел СабСегмент " + Строка.SubSegment + " Пропустил строку для ТЧ SubGeomarket_Segment";
			Message.Message();
			продолжить
		КонецЕсли;


		
		Отбор = новый Структура;
		Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.SubGeomarket_Segment);
		Отбор.Вставить("GroupLevel", Справочники.GeoMarkets.НайтиПоКоду(Строка.SubGeomarket));
		Отбор.Вставить("SubLevel", Справочники.Сегменты.НайтиПоКоду(Строка.Segment));
		
		РезультатSubGeomarket_Segment_ = Результат.Скопировать(Отбор);
		
		СтрокаSubGeomarket_SubSegment = ДокументПроцентов.Sub_Segment.Добавить();
		
		Если РезультатSubGeomarket_Segment_.Количество() > 0 тогда
			
			Отбор = новый Структура;
			Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.Sub_Segment);
			Отбор.Вставить("GroupLevel", РезультатSubGeomarket_Segment_[0].ссылка);
			Отбор.Вставить("SubLevel", Справочники.Сегменты.НайтиПоКоду(Строка.SubSegment));
			
			РезультатSubGeomarket_SubSegment = Результат.Скопировать(Отбор); 
			
			Если РезультатSubGeomarket_SubSegment.Количество() > 0 тогда
				
				СтрокаSubGeomarket_SubSegment.BudgetItem = РезультатSubGeomarket_SubSegment[0].Ссылка;
				
			Иначе
				
				SubSegment = Справочники.rgsBudgetItem.СоздатьЭлемент();
				SubSegment.BudgetPercentType = Перечисления.rgsBudgetPercentTypes.Sub_Segment;
				SubSegment.GroupLevel = РезультатSubGeomarket_Segment_[0].ссылка;
				SubSegment.SubLevel = Справочники.Сегменты.НайтиПоКоду(Строка.SubSegment);
				SubSegment.Наименование = "" + Перечисления.rgsBudgetPercentTypes.Sub_Segment + "/" +  РезультатSubGeomarket_Segment_[0].ссылка + "/" + Строка.SubSegment;
				SubSegment.Записать(); 
				
				СтрокаSubGeomarket_SubSegment.BudgetItem = SubSegment.Ссылка;
				СтрокаSubGeomarket_SubSegment.Group_Level = SubSegment.Ссылка.Sublevel;
				
			КонецЕсли;
			
			
		Иначе
			
			SubGeomarketSubSegment = Справочники.rgsBudgetItem.СоздатьЭлемент();
			SubGeomarketSubSegment.BudgetPercentType = Перечисления.rgsBudgetPercentTypes.SubGeomarket_Segment;
			SubGeomarketSubSegment.GroupLevel = Справочники.GeoMarkets.НайтиПоКоду(Строка.SubGeomarket);
			SubGeomarketSubSegment.SubLevel = Справочники.Сегменты.НайтиПоКоду(Строка.Segment);
			SubGeomarketSubSegment.Наименование = "" + Перечисления.rgsBudgetPercentTypes.SubGeomarket_Segment + "/" +  Строка.SubGeomarket + "/" + Строка.Segment;
			SubGeomarketSubSegment.Записать();
			
			Отбор = новый Структура;
			Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.Sub_Segment);
			Отбор.Вставить("GroupLevel", SubGeomarketSubSegment.ссылка);
			Отбор.Вставить("SubLevel", Справочники.Сегменты.НайтиПоКоду(Строка.SubSegment));
			
			РезультатSubGeomarket_SubSegment = Результат.Скопировать(Отбор); 
			
			Если РезультатSubGeomarket_SubSegment.Количество() > 0 тогда
				
				СтрокаSubGeomarket_SubSegment.BudgetItem = SubGeomarketSubSegment.Ссылка;
				СтрокаSubGeomarket_SubSegment.Group_Level = РезультатSubGeomarket_SubSegment[0].Ссылка.Sublevel;
				
			Иначе
				
				SubSegment = Справочники.rgsBudgetItem.СоздатьЭлемент();
				SubSegment.BudgetPercentType = Перечисления.rgsBudgetPercentTypes.Sub_Segment;
				SubSegment.GroupLevel = SubGeomarketSubSegment.ссылка;
				SubSegment.SubLevel = Справочники.Сегменты.НайтиПоКоду(Строка.SubSegment);
				SubSegment.Наименование = "" + Перечисления.rgsBudgetPercentTypes.Sub_Segment + "/" +  SubGeomarketSubSegment.ссылка + "/" + Строка.SubSegment;
				SubSegment.Записать(); 
				
				СтрокаSubGeomarket_SubSegment.BudgetItem = SubSegment.Ссылка;
				СтрокаSubGeomarket_SubSegment.Group_Level = SubSegment.Ссылка.Sublevel;
				
			КонецЕсли;
			
			
		КонецЕсли;
		
		СтрокаSubGeomarket_SubSegment.Percent = Строка.Percent;
		
		
	КонецЦикла;
	
	ДокументПроцентов.Дата = ТекущаяДата();
	ДокументПроцентов.Записать();
	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьВБазу(Команда)
	
	ЗаписатьВБазуНаСервере()	
	
КонецПроцедуры
