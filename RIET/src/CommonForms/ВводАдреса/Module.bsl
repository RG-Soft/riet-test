
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("Представление") Тогда 
		Представление = Параметры.Представление;
	КонецЕсли;
	
	КодСтраны = "643";
	мНаВходеКодРегиона = Ложь;
	
	Если РегламентированнаяОтчетность.ПустоеЗначение(Индекс) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(КодРегиона) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(Регион) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(Район) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(Город) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(НаселенныйПункт) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(Улица) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(Дом) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(Корпус) 
	   И РегламентированнаяОтчетность.ПустоеЗначение(Квартира) 
	   И НЕ ПустаяСтрока(Представление) Тогда
	   
	   РазобратьПредставление();
	   
	КонецЕсли;
	
	СформироватьПредставление();
	
КонецПроцедуры
               
&НаКлиенте
Процедура ОК(Команда)
	
	Закрыть(Представление);
	
КонецПроцедуры


&НаКлиенте
Функция ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус)
	
	Инд = КонтактнаяИнформация.ПолучитьИндекс(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	Если ПустаяСтрока(Инд) Тогда
		Возврат Индекс;
	Иначе
		Возврат Инд;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура РегионПриИзменении(Элемент)
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	КодРегионаПоНазв = РегламентированнаяОтчетность.КодРегионаПоНазванию(Регион);
	КодРегиона = ?(КодРегионаПоНазв = "", КодРегиона, КодРегионаПоНазв);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура РайонПриИзменении(Элемент)
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура ГородПриИзменении(Элемент)
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура НаселенныйПунктПриИзменении(Элемент)
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура УлицаПриИзменении(Элемент)
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура ДомПриИзменении(Элемент)

	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();

КонецПроцедуры

&НаКлиенте
Процедура КорпусПриИзменении(Элемент)

	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();

КонецПроцедуры

&НаКлиенте
Процедура КвартираПриИзменении(Элемент)

	СформироватьПредставление();

КонецПроцедуры

&НаКлиенте
Процедура ИндексПриИзменении(Элемент)

	СформироватьПредставление();

КонецПроцедуры

&НаКлиенте
Процедура РегионНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СписокСокращений = КонтактнаяИнформация.ПолучитьСписокСокращений(Регион, 1);
	
	Если СписокСокращений <> Неопределено Тогда
		Сокращение = ВыбратьИзСписка(СписокСокращений,Элемент);
		Если Сокращение <> Неопределено Тогда
			Регион = СокрЛП(Регион) + " " + СокрЛП(Сокращение.Значение);
		КонецЕсли;
	КонецЕсли;
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура РайонНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СписокСокращений = КонтактнаяИнформация.ПолучитьСписокСокращений(Район, 2);
	
	Если СписокСокращений <> Неопределено Тогда
		Сокращение = ВыбратьИзСписка(СписокСокращений,Элемент);
		Если Сокращение <> Неопределено Тогда
			Район = СокрЛП(Район) + " " + СокрЛП(Сокращение.Значение);
		КонецЕсли;
	КонецЕсли;
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура ГородНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СписокСокращений = КонтактнаяИнформация.ПолучитьСписокСокращений(Город, 3);
	
	Если СписокСокращений <> Неопределено Тогда
		Сокращение = ВыбратьИзСписка(СписокСокращений,Элемент);
		Если Сокращение <> Неопределено Тогда
			Город = СокрЛП(Город) + " " + СокрЛП(Сокращение.Значение);
		КонецЕсли;
	КонецЕсли;
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура НаселенныйПунктНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СписокСокращений = КонтактнаяИнформация.ПолучитьСписокСокращений(НаселенныйПункт, 4);
	
	Если СписокСокращений <> Неопределено Тогда
		Сокращение = ВыбратьИзСписка(СписокСокращений,Элемент);
		Если Сокращение <> Неопределено Тогда
			НаселенныйПункт = СокрЛП(НаселенныйПункт) + " " + СокрЛП(Сокращение.Значение);
		КонецЕсли;
	КонецЕсли;
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура УлицаНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СписокСокращений = КонтактнаяИнформация.ПолучитьСписокСокращений(Улица, 5);
	
	Если СписокСокращений <> Неопределено Тогда
		Сокращение = ВыбратьИзСписка(СписокСокращений,Элемент);
		Если Сокращение <> Неопределено Тогда
			Улица = СокрЛП(Улица) + " " + СокрЛП(Сокращение.Значение);
		КонецЕсли;
	КонецЕсли;
	
	Индекс = ПолучитьИндексЛокальная(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Корпус);
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура РайонОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	АдреснаяЗапись = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(ВыбранноеЗначение.Код);
	Элемент.Значение = СокрЛП(АдреснаяЗапись.Наименование) + " " + СокрЛП(АдреснаяЗапись.Сокращение);
	ЗаполнитьРодителей(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Индекс, АдреснаяЗапись);
	СформироватьПредставление();

КонецПроцедуры

&НаКлиенте
Процедура ГородОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	АдреснаяЗапись = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(ВыбранноеЗначение.Код);
	Элемент.Значение = СокрЛП(АдреснаяЗапись.Наименование) + " " + СокрЛП(АдреснаяЗапись.Сокращение);
	ЗаполнитьРодителей(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Индекс, АдреснаяЗапись);
	СформироватьПредставление();

КонецПроцедуры

&НаКлиенте
Процедура НаселенныйПунктОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	АдреснаяЗапись = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(ВыбранноеЗначение.Код);
	Элемент.Значение = СокрЛП(АдреснаяЗапись.Наименование) + " " + СокрЛП(АдреснаяЗапись.Сокращение);
	ЗаполнитьРодителей(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Индекс, АдреснаяЗапись);
	СформироватьПредставление();

КонецПроцедуры

&НаКлиенте
Процедура УлицаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	АдреснаяЗапись = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(ВыбранноеЗначение.Код);
	Элемент.Значение = СокрЛП(АдреснаяЗапись.Наименование) + " " + СокрЛП(АдреснаяЗапись.Сокращение);
	ЗаполнитьРодителей(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Индекс, АдреснаяЗапись);
	СформироватьПредставление();

КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьРодителей(Регион, Район, Город, НаселенныйПункт, Улица, Дом, Индекс, Элемент) Экспорт

	Если Элемент.ТипАдресногоЭлемента > 5 Тогда
		АдресныйЭлемент = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(Элемент.Код - Элемент.Код%КонтактнаяИнформация.МаскаДома());
		Если АдресныйЭлемент.ТипАдресногоЭлемента = 6 Тогда
			Дом = КонтактнаяИнформация.ПолучитьНазвание(АдресныйЭлемент);
		Иначе
			Дом = "";
		КонецЕсли;
	КонецЕсли;

	Если Элемент.ТипАдресногоЭлемента > 4 Тогда
		АдресныйЭлемент = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(Элемент.Код - Элемент.Код%КонтактнаяИнформация.МаскаУлицы());
		Если АдресныйЭлемент.ТипАдресногоЭлемента = 5 Тогда
			Улица = КонтактнаяИнформация.ПолучитьНазвание(АдресныйЭлемент);
		Иначе
			Улица = "";
		КонецЕсли;
	КонецЕсли;

	Если Элемент.ТипАдресногоЭлемента > 3 Тогда
		АдресныйЭлемент = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(Элемент.Код - Элемент.Код%КонтактнаяИнформация.МаскаНасПункта());
		Если АдресныйЭлемент.ТипАдресногоЭлемента = 4 Тогда
			НаселенныйПункт = КонтактнаяИнформация.ПолучитьНазвание(АдресныйЭлемент);
		Иначе
			НаселенныйПункт = "";
		КонецЕсли;
	КонецЕсли;

	Если Элемент.ТипАдресногоЭлемента > 2 Тогда
		АдресныйЭлемент = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(Элемент.Код - Элемент.Код%КонтактнаяИнформация.МаскаГорода());
		Если АдресныйЭлемент.ТипАдресногоЭлемента = 3 Тогда
			Город = КонтактнаяИнформация.ПолучитьНазвание(АдресныйЭлемент);
		Иначе
			Город = "";
		КонецЕсли;
	КонецЕсли;

	Если Элемент.ТипАдресногоЭлемента > 1 Тогда
		АдресныйЭлемент = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(Элемент.Код - Элемент.Код%КонтактнаяИнформация.МаскаРайона());
		Если АдресныйЭлемент.ТипАдресногоЭлемента = 2 Тогда
			Район = КонтактнаяИнформация.ПолучитьНазвание(АдресныйЭлемент);
		Иначе
			Район = "";
		КонецЕсли;
	КонецЕсли;

	АдресныйЭлемент = КонтактнаяИнформация.ПолучитьСтруктуруАдресногоЭлемента(Элемент.Код - Элемент.Код%КонтактнаяИнформация.МаскаРегиона());
	Если АдресныйЭлемент.ТипАдресногоЭлемента = 1 Тогда
		Регион = КонтактнаяИнформация.ПолучитьНазвание(АдресныйЭлемент);
	Иначе
		Регион = "";
	КонецЕсли;

	Если НЕ ПустаяСтрока(Элемент.Индекс) Тогда
		Индекс = Элемент.Индекс;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура СформироватьПредставление()
	
	Представление = 
					СокрЛП(КодСтраны) + "," 
				  + СокрЛП(Индекс) + ","
				  + ?(мНаВходеКодРегиона, СокрЛП(КодРегиона), СокрЛП(Регион)) + ","
				  + СокрЛП(Район) + ","
				  + СокрЛП(Город) + ","
				  + СокрЛП(НаселенныйПункт) + ","
				  + СокрЛП(Улица) + ","
				  + СокрЛП(Дом) + ","
				  + СокрЛП(Корпус) + ","
				  + СокрЛП(Квартира);
				  
	Представление = ПредставлениеАдресаВФормате9Запятых(Представление);

КонецПроцедуры
			  
&НаСервере
Процедура РазобратьПредставление()			  
	
	СписокПараметров = Новый СписокЗначений;
	
	ПредыдущаяЗапятая = 0;
	Для Сч = 1 По СтрДлина(Представление) Цикл
		ТекСимв = Сред(Представление, Сч, 1);
		Если ТекСимв = "," Тогда
			СписокПараметров.Добавить(Сред(Представление, ПредыдущаяЗапятая + 1, Сч - (ПредыдущаяЗапятая + 1)));
			ПредыдущаяЗапятая = Сч;
		КонецЕсли;
	КонецЦикла;
	
	Если ПредыдущаяЗапятая <> СтрДлина(Представление) Тогда
		СписокПараметров.Добавить(Сред(Представление, ПредыдущаяЗапятая + 1, СтрДлина(Представление) - ПредыдущаяЗапятая));
	КонецЕсли;
	
	Для Сч = СписокПараметров.Количество() + 1 По 10 Цикл
		
		СписокПараметров.Добавить("");
		
	КонецЦикла;
	
	КодСтраны = СписокПараметров.Получить(0);
	Индекс = СписокПараметров.Получить(1);
	Если ОбщегоНазначения.ЕстьНеЦифры(СписокПараметров.Получить(2)) ИЛИ ПустаяСтрока(СписокПараметров.Получить(2)) Тогда
		мНаВходеКодРегиона = Ложь;
		Регион = СписокПараметров.Получить(2);
		КодРегиона = РегламентированнаяОтчетность.КодРегионаПоНазванию(Регион);
	Иначе
		мНаВходеКодРегиона = Истина;
		КодРегиона = СписокПараметров.Получить(2);
		Регион = НазваниеРегионаПоКоду(КодРегиона);
	КонецЕсли;
	Район = СписокПараметров.Получить(3);
	Город = СписокПараметров.Получить(4);
	НаселенныйПункт = СписокПараметров.Получить(5);
	Улица = СписокПараметров.Получить(6);
	Дом = СписокПараметров.Получить(7);
	Корпус = СписокПараметров.Получить(8);
	Квартира = СписокПараметров.Получить(9);
		
КонецПроцедуры
                             
&НаСервереБезКонтекста
Функция НазваниеРегионаПоКоду(КодРег)
	
	Если РегламентированнаяОтчетность.ПустоеЗначение(КодРег) Тогда
		Возврат "";
	КонецЕсли;
	
	Попытка 
		КодРегЧисло = Число(КодРег);
	Исключение
		Возврат "";
	КонецПопытки;
		
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	АдресныйКлассификатор.КодРегионаВКоде,
	               |	АдресныйКлассификатор.ТипАдресногоЭлемента,
	               |	АдресныйКлассификатор.Наименование,
	               |	АдресныйКлассификатор.Код
	               |ИЗ
	               |	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
	               |
	               |ГДЕ
	               |	АдресныйКлассификатор.ТипАдресногоЭлемента = &ТипАдресногоЭлемента И
	               |	АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде";
	
	Запрос.УстановитьПараметр("КодРегионаВКоде", КодРегЧисло);
	Запрос.УстановитьПараметр("ТипАдресногоЭлемента", 1);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Количество() > 0 Тогда
		
		Выборка.Следующий();
		Возврат КонтактнаяИнформация.ПолучитьПолноеНазвание(Выборка.Код);
		
	Иначе
		
		Возврат "";
		
	КонецЕсли;
	
КонецФункции
    
&НаКлиенте
Процедура КодСтраныПриИзменении(Элемент)
	
	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Процедура ПолеНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Уровень = ПолучитьУровеньЭлемента(Элемент);
	СтруктураАдреса = ПолучитьСтруктуруАдреса();
	СтруктураАдреса.Вставить("Уровень", Уровень);
	
	// При подборе из формы необходимо, чтобы был заполнен регион, в противном случае получится пустой список
	
	Отказ = Ложь;
	Если Элемент.Имя <> "Регион" Тогда
		Если ПустаяСтрока(Регион) Тогда
			ОчиститьСообщения();
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ВернутьСтр("ru = 'Укажите регион.'"), , "Регион");
			Отказ = Истина;
		Иначе
			Отказ = ПередВыборомАдресногоЭлемента(Регион, Истина);
		КонецЕсли;
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// Открываем форму подбора адреса
	СтруктураРезультата = ОткрытьФормуМодально("РегистрСведений.АдресныйКлассификатор.Форма.ФормаВыбораУправляемая", СтруктураАдреса);
	
	Если СтруктураРезультата <> Неопределено Тогда 
		
		ЭтаФорма[Элемент.Имя] = СокрЛП(СтруктураРезультата.Наименование + " " + СтруктураРезультата.Сокращение);
		ПолеИзменилось = (ЭтаФорма[Элемент.Имя] <> СокрЛП(Элемент.ТекстРедактирования));
		ЗаписатьСтруктуруАдреса(СтруктураРезультата.СтруктураАдреса);
		
		Для Каждого Ошибка ИЗ СтруктураРезультата.СтруктураОшибок Цикл
			ОчиститьСообщения();
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Ошибка.Значение, , Ошибка.Ключ);
		КонецЦикла;
		
		//Если Элемент.Имя = "Регион" Тогда
		//	ЗагрузитьРегион(СтруктураРезультата.МожноЗагружатьРегион);
		//КонецЕсли;
		
		//Если ПустаяСтрока(КодРегиона) Тогда
			РезультатКодРегиона = Неопределено;
			Если СтруктураРезультата.Свойство("КодРегиона", РезультатКодРегиона) <> Неопределено Тогда 
				КодРегиона = РезультатКодРегиона;
			КонецЕсли;	
		//КонецЕсли;
		
	КонецЕсли;

	СформироватьПредставление();
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьУровеньЭлемента(Элемент)
	
	Если Элемент = Элементы.Регион Тогда
		Возврат 1;
		
	ИначеЕсли Элемент = Элементы.Район Тогда
		Возврат 2;
		
	ИначеЕсли Элемент = Элементы.Город Тогда
		Возврат 3;
		
	ИначеЕсли Элемент = Элементы.НаселенныйПункт Тогда
		Возврат 4;
		
	ИначеЕсли Элемент = Элементы.Улица Тогда
		Возврат 5;
		
	ИначеЕсли Элемент = Элементы.Дом ИЛИ Элемент = Элементы.Корпус Тогда
		Возврат 6;
		
	Иначе
		Возврат 0;
	КонецЕсли;
		
КонецФункции

&НаСервереБезКонтекста
Функция ПередВыборомАдресногоЭлемента(Регион, ПроверяетсяРегион)
	
	Если Не ПроверяетсяРегион И НЕ ПустаяСтрока(Регион) Тогда
		
		РегионЗагружен = АдресныйЭлементЗагружен(Регион);
		Если Не РегионЗагружен Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

&НаКлиенте
Функция ПолучитьСтруктуруАдреса()
	
	СтруктураАдреса = Новый Структура();
	СтруктураАдреса.Вставить("Индекс", Индекс);
	СтруктураАдреса.Вставить("Регион", Регион);
	СтруктураАдреса.Вставить("Район", Район);
	СтруктураАдреса.Вставить("Город", Город);
	СтруктураАдреса.Вставить("НаселенныйПункт", НаселенныйПункт);
	СтруктураАдреса.Вставить("Улица", Улица);
	СтруктураАдреса.Вставить("Дом", Дом);
	СтруктураАдреса.Вставить("Корпус", Корпус);
	СтруктураАдреса.Вставить("Квартира", Квартира);
	Возврат СтруктураАдреса;
	
КонецФункции

&НаКлиенте
Процедура ЗаписатьСтруктуруАдреса(СтруктураАдреса)
	
	Если Индекс <> СтруктураАдреса.Индекс Тогда
		Индекс = СтруктураАдреса.Индекс;
	КонецЕсли;
	Если Регион <> СтруктураАдреса.Регион Тогда
		Регион = СтруктураАдреса.Регион;
	КонецЕсли;
	Если Район <> СтруктураАдреса.Район Тогда
		Район = СтруктураАдреса.Район;
	КонецЕсли;
	Если Город <> СтруктураАдреса.Город Тогда
		Город = СтруктураАдреса.Город;
	КонецЕсли;
	Если НаселенныйПункт <> СтруктураАдреса.НаселенныйПункт Тогда
		НаселенныйПункт = СтруктураАдреса.НаселенныйПункт;
	КонецЕсли;
	Если Улица <> СтруктураАдреса.Улица Тогда
		Улица = СтруктураАдреса.Улица;
	КонецЕсли;
	Если Дом <> СтруктураАдреса.Дом Тогда
		Дом = СтруктураАдреса.Дом;
	КонецЕсли;
	Если Корпус <> СтруктураАдреса.Корпус Тогда
		Корпус = СтруктураАдреса.Корпус;
	КонецЕсли;
	Если Квартира <> СтруктураАдреса.Квартира Тогда
		Квартира = СтруктураАдреса.Квартира;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция АдресныйЭлементЗагружен(Знач НазваниеРегиона, Знач НазваниеРайона = "", Знач НазваниеГорода = "", 
	Знач НазваниеНаселенногоПункта = "", Знач НазваниеУлицы = "", Уровень = 1) Экспорт
	
	// СтандартныеПодсистемы.АдресныйКлассификатор
	Родитель = ПолучитьПустуюСтруктуруАдреса();
	Регион = ПолучитьАдресныйЭлемент(НазваниеРегиона, 1,  Родитель);
	
	Если Уровень > 1 Тогда
		
		Если Регион.Код > 0 Тогда
			Родитель = Регион;
		КонецЕсли;
		Район = ПолучитьАдресныйЭлемент(НазваниеРайона, 2, Родитель);
		
		Если Уровень > 2 Тогда
			
			Если Район.Код > 0 Тогда
				Родитель = Район;
			КонецЕсли;
			Город = ПолучитьАдресныйЭлемент(НазваниеГорода, 3, Родитель);
			
			Если Уровень > 3 Тогда
				
				Если Город.Код > 0 Тогда
					Родитель = Город;
				КонецЕсли;
				НаселенныйПункт = ПолучитьАдресныйЭлемент(НазваниеНаселенногоПункта, 4, Родитель);
				
				Если Уровень > 4 Тогда
					
					Если НаселенныйПункт.Код > 0 Тогда
						Родитель = НаселенныйПункт;
					КонецЕсли;
					Улица = ПолучитьАдресныйЭлемент(НазваниеУлицы, 5, Родитель);
					
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	// Если не указан уровень или указан 1й уровень, то проверяем существование всех уровней
	Если Уровень = 1 Тогда
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	АдресныйКлассификатор.Код КАК Код
		|ИЗ
		|	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
		|ГДЕ
		|	АдресныйКлассификатор.ТипАдресногоЭлемента <> 1
		|	И АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде";
		Запрос.УстановитьПараметр("КодРегионаВКоде", Регион.КодРегионаВКоде);
		
	// Если указан 2й уровень, то проверяем существование районов в регионе
	ИначеЕсли Уровень = 2 Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	АдресныйКлассификатор.Код КАК Код
		|ИЗ
		|	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
		|ГДЕ
		|	АдресныйКлассификатор.ТипАдресногоЭлемента = 2
		|	И АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде";
		Запрос.УстановитьПараметр("КодРегионаВКоде", Регион.КодРегионаВКоде);
		
	// Если указан 3й уровень, то проверяем существование городов в районе
	ИначеЕсли Уровень = 3 Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	АдресныйКлассификатор.Код КАК Код
		|ИЗ
		|	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
		|ГДЕ
		|	АдресныйКлассификатор.ТипАдресногоЭлемента = 3
		|	И АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде
		|	И АдресныйКлассификатор.КодРайонаВКоде = &КодРайонаВКоде";
		Запрос.УстановитьПараметр("КодРегионаВКоде", Регион.КодРегионаВКоде);
		Запрос.УстановитьПараметр("КодРайонаВКоде", Район.КодРайонаВКоде);
		
	// Если указан 4й уровень, то проверяем существование населенных пунктов в городе
	ИначеЕсли Уровень = 4 Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	АдресныйКлассификатор.Код КАК Код
		|ИЗ
		|	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
		|ГДЕ
		|	АдресныйКлассификатор.ТипАдресногоЭлемента = 4
		|	И АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде
		|	И АдресныйКлассификатор.КодРайонаВКоде = &КодРайонаВКоде
		|	И АдресныйКлассификатор.КодГородаВКоде = &КодГородаВКоде";
		Запрос.УстановитьПараметр("КодРегионаВКоде", Регион.КодРегионаВКоде);
		Запрос.УстановитьПараметр("КодРайонаВКоде", Район.КодРайонаВКоде);
		Запрос.УстановитьПараметр("КодГородаВКоде", Город.КодГородаВКоде);
		
	// Если указан 5й уровень, то проверяем существование улиц в населенном пункте
	ИначеЕсли Уровень = 5 Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	АдресныйКлассификатор.Код КАК Код
		|ИЗ
		|	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
		|ГДЕ
		|	АдресныйКлассификатор.ТипАдресногоЭлемента = 5
		|	И АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде
		|	И АдресныйКлассификатор.КодРайонаВКоде = &КодРайонаВКоде
		|	И АдресныйКлассификатор.КодГородаВКоде = &КодГородаВКоде
		|	И АдресныйКлассификатор.КодНаселенногоПунктаВКоде = &КодНаселенногоПунктаВКоде";
		Запрос.УстановитьПараметр("КодРегионаВКоде", Регион.КодРегионаВКоде);
		Запрос.УстановитьПараметр("КодРайонаВКоде", Район.КодРайонаВКоде);
		Запрос.УстановитьПараметр("КодГородаВКоде", Город.КодГородаВКоде);
		Запрос.УстановитьПараметр("КодНаселенногоПунктаВКоде", НаселенныйПункт.КодНаселенногоПунктаВКоде);
		
	// Если указан 6й уровень, то проверяем существование домов на улице
	ИначеЕсли Уровень = 6 Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	АдресныйКлассификатор.Код КАК Код
		|ИЗ
		|	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
		|ГДЕ
		|	АдресныйКлассификатор.ТипАдресногоЭлемента = 6
		|	И АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде
		|	И АдресныйКлассификатор.КодРайонаВКоде = &КодРайонаВКоде
		|	И АдресныйКлассификатор.КодГородаВКоде = &КодГородаВКоде
		|	И АдресныйКлассификатор.КодНаселенногоПунктаВКоде = &КодНаселенногоПунктаВКоде
		|	И АдресныйКлассификатор.КодУлицыВКоде = &КодУлицыВКоде";
		Запрос.УстановитьПараметр("КодРегионаВКоде", Регион.КодРегионаВКоде);
		Запрос.УстановитьПараметр("КодРайонаВКоде", Район.КодРайонаВКоде);
		Запрос.УстановитьПараметр("КодГородаВКоде", Город.КодГородаВКоде);
		Запрос.УстановитьПараметр("КодНаселенногоПунктаВКоде", НаселенныйПункт.КодНаселенногоПунктаВКоде);
		Запрос.УстановитьПараметр("КодУлицыВКоде", Улица.КодУлицыВКоде);
	КонецЕсли;
	
	Результат = Запрос.Выполнить();
	Возврат Не Результат.Пустой();
	// Конец СтандартныеПодсистемы.АдресныйКлассификатор

	Возврат Ложь;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьАдресныйЭлемент(знач НазваниеЭлемента, ТипЭлемента, ЭлементРодитель)

	Если (СокрЛП(НазваниеЭлемента) = "") ИЛИ (ТипЭлемента = 0) Тогда
		Возврат ПолучитьПустуюСтруктуруАдреса();
	КонецЕсли;
	
	// смотрим есть ли в имени адресное сокращение этого уровня
	// если есть, то ищем по наименованию и адресному сокращению
	АдресноеСокращение = "";
	НазваниеЭлемента = УправлениеКонтактнойИнформацией.ПолучитьИмяИАдресноеСокращение(НазваниеЭлемента, АдресноеСокращение);

	Запрос = Новый Запрос();
	
	ОграничениеПоКоду = "";
	Если ЭлементРодитель.Код > 0 Тогда // проверка на соответствие подчинению родителю
		
		Если ЭлементРодитель.ТипАдресногоЭлемента <= 5 Тогда
			
			Если ЭлементРодитель.КодРегионаВКоде <> 0 Тогда
				ОграничениеПоКоду = ОграничениеПоКоду + Символы.ПС 
				+ "  И (АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде)";
				Запрос.УстановитьПараметр("КодРегионаВКоде", ЭлементРодитель.КодРегионаВКоде);
			КонецЕсли;
			
			Если ЭлементРодитель.КодРайонаВКоде <> 0 Тогда
				ОграничениеПоКоду = ОграничениеПоКоду + Символы.ПС 
				+ "  И (АдресныйКлассификатор.КодРайонаВКоде = &КодРайонаВКоде)";
				Запрос.УстановитьПараметр("КодРайонаВКоде", ЭлементРодитель.КодРайонаВКоде);
			КонецЕсли;
			
			Если ЭлементРодитель.КодГородаВКоде <> 0 Тогда
				ОграничениеПоКоду = ОграничениеПоКоду + Символы.ПС 
				+ "  И (АдресныйКлассификатор.КодГородаВКоде = &КодГородаВКоде)";
				Запрос.УстановитьПараметр("КодГородаВКоде", ЭлементРодитель.КодГородаВКоде);
			КонецЕсли;
			
			Если ЭлементРодитель.КодНаселенногоПунктаВКоде <> 0 Тогда
				ОграничениеПоКоду = ОграничениеПоКоду + Символы.ПС 
				+ "  И (АдресныйКлассификатор.КодНаселенногоПунктаВКоде = &КодНаселенногоПунктаВКоде)";
				Запрос.УстановитьПараметр("КодНаселенногоПунктаВКоде", ЭлементРодитель.КодНаселенногоПунктаВКоде);
			КонецЕсли;
			
			Если ЭлементРодитель.КодУлицыВКоде <> 0 Тогда
				ОграничениеПоКоду = ОграничениеПоКоду + Символы.ПС 
				+ "  И (АдресныйКлассификатор.КодУлицыВКоде = &КодУлицыВКоде)";
				Запрос.УстановитьПараметр("КодУлицыВКоде", ЭлементРодитель.КодУлицыВКоде);
			КонецЕсли;
		
		КонецЕсли;
		
	КонецЕсли;
	
	// ограничение на адресное сокращение
	Если АдресноеСокращение <> "" Тогда
		ОграничениеПоКоду = ОграничениеПоКоду + Символы.ПС + "  И (АдресныйКлассификатор.Сокращение = &АдресноеСокращение)";
		Запрос.УстановитьПараметр("АдресноеСокращение", АдресноеСокращение);
	КонецЕсли;
	
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	АдресныйКлассификатор.Код КАК Код,
	|	АдресныйКлассификатор.КодРегионаВКоде КАК КодРегионаВКоде,
	|	АдресныйКлассификатор.Наименование КАК Наименование,
	|	АдресныйКлассификатор.Сокращение КАК Сокращение,
	|	АдресныйКлассификатор.Индекс КАК Индекс,
	|	АдресныйКлассификатор.ТипАдресногоЭлемента КАК ТипАдресногоЭлемента,
	|	АдресныйКлассификатор.КодРайонаВКоде КАК КодРайонаВКоде,
	|	АдресныйКлассификатор.КодГородаВКоде КАК КодГородаВКоде,
	|	АдресныйКлассификатор.КодНаселенногоПунктаВКоде КАК КодНаселенногоПунктаВКоде,
	|	АдресныйКлассификатор.КодУлицыВКоде КАК КодУлицыВКоде,
	|	0 КАК ПризнакАктуальности
	|ИЗ
	|	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
	|ГДЕ
	|	АдресныйКлассификатор.ТипАдресногоЭлемента = &ТипАдресногоЭлемента
	|	И АдресныйКлассификатор.Наименование = &Наименование" +
	ОграничениеПоКоду;
	
	Запрос.УстановитьПараметр("ТипАдресногоЭлемента", ТипЭлемента);
	Запрос.УстановитьПараметр("Наименование", НазваниеЭлемента);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат ПолучитьПустуюСтруктуруАдреса();
	Иначе
		
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		РезультирующаяСтруктура = Новый Структура;
		Для Каждого Колонка Из РезультатЗапроса.Колонки Цикл
			РезультирующаяСтруктура.Вставить(Колонка.Имя, Выборка[Колонка.Имя]);
		КонецЦикла;
		Возврат РезультирующаяСтруктура;
		
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьПустуюСтруктуруАдреса()
	
	Возврат Новый Структура("Код,Наименование,Сокращение,ТипАдресногоЭлемента,Индекс,
	|КодРегионаВКоде,КодРайонаВКоде,КодГородаВКоде,КодНаселенногоПунктаВКоде,КодУлицыВКоде,
	|ПризнакАктульности", 0, "", "", 0, "", 0, 0, 0, 0, 0, 0);
	
КонецФункции

&НаСервере
Функция ПредставлениеАдресаВФормате9Запятых(Знач АдресВФормате9Запятых, АнализироватьРегион = Ложь) Экспорт
	
	Если (СтрЧислоВхождений(АдресВФормате9Запятых, ",") <> 9 И СтрЧислоВхождений(АдресВФормате9Запятых, ",") <> 12) ИЛИ (Лев(АдресВФормате9Запятых, 3) <> "643" И Лев(АдресВФормате9Запятых, 3) <> "999") Тогда
		Возврат АдресВФормате9Запятых;
	КонецЕсли;
	
	КопияАдреса = АдресВФормате9Запятых;
	
	ПоследняяКоордината = 0;
	СоставляющиеАдреса = Новый Массив;
	КоординатыЗапятых = Новый Массив;
	Для Сч = 1 По 12 Цикл
		КоординатаЗапятой = СтрНайти(КопияАдреса, ",");
		Если КоординатаЗапятой > 0 Тогда
			КоординатыЗапятых.Добавить(ПоследняяКоордината + КоординатаЗапятой);
			ПоследняяКоордината = ПоследняяКоордината + КоординатаЗапятой;
			КопияАдреса = Сред(КопияАдреса, КоординатаЗапятой + 1);
		Иначе
			Прервать;
		КонецЕсли;	
	КонецЦикла;
	
	КоличествоЗапятых = КоординатыЗапятых.Количество();

	СоставляющиеАдреса.Добавить(СокрЛП(Лев(АдресВФормате9Запятых, КоординатыЗапятых[0] - 1)));
	Для Сч = 0 По КоличествоЗапятых - 2 Цикл
		СоставляющиеАдреса.Добавить(СокрЛП(Сред(АдресВФормате9Запятых, КоординатыЗапятых[Сч] + 1, КоординатыЗапятых[Сч + 1] - (КоординатыЗапятых[Сч] + 1))));
	КонецЦикла;
	СоставляющиеАдреса.Добавить(СокрЛП(Сред(АдресВФормате9Запятых, КоординатыЗапятых[КоличествоЗапятых - 1] + 1)));
	
	ТекПредставление = "";
	
	ТипДома     = "дом";
    Если КоличествоЗапятых > 9 Тогда
		ТипДома = ?(ПустаяСтрока(СоставляющиеАдреса[10]), ТипДома, СоставляющиеАдреса[10]);
	КонецЕсли;	
	ТипКорпуса  = "корпус";
    Если КоличествоЗапятых > 10 Тогда
		ТипКорпуса = ?(ПустаяСтрока(СоставляющиеАдреса[11]), ТипКорпуса, СоставляющиеАдреса[11]);
	КонецЕсли;	
	ТипКвартиры = "кв.";
    Если КоличествоЗапятых > 11 Тогда
		ТипКвартиры = ?(ПустаяСтрока(СоставляющиеАдреса[12]), ТипКвартиры, СоставляющиеАдреса[12]);
	КонецЕсли;	
	
	Если СокрЛП(СоставляющиеАдреса[1]) <> "" Тогда
		ТекПредставление = ТекПредставление + ", " + СокрЛП(СоставляющиеАдреса[1]);
	КонецЕсли;

	Если СокрЛП(СоставляющиеАдреса[2]) <> "" Тогда
		Регион = СокрЛП(СоставляющиеАдреса[2]);
		Если АнализироватьРегион Тогда
			Если ОбщегоНазначения.ТолькоЦифрыВСтроке(Регион) Тогда
				Регион = ПолучитьНазваниеРегионаПоКоду(Регион);
			КонецЕсли;
		КонецЕсли;

		ТекПредставление = ТекПредставление + ", " + Регион;
	КонецЕсли;

	Если СокрЛП(СоставляющиеАдреса[3]) <> "" Тогда
		ТекПредставление = ТекПредставление + ", " + СокрЛП(СоставляющиеАдреса[3]);
	КонецЕсли;

	Если СокрЛП(СоставляющиеАдреса[4]) <> "" Тогда
		ТекПредставление = ТекПредставление + ", " + СокрЛП(СоставляющиеАдреса[4]);
	КонецЕсли;

	Если СокрЛП(СоставляющиеАдреса[5]) <> "" Тогда
		ТекПредставление = ТекПредставление + ", " + СокрЛП(СоставляющиеАдреса[5]);
	КонецЕсли;

	Если СокрЛП(СоставляющиеАдреса[6]) <> "" Тогда
		ТекПредставление = ТекПредставление + ", " + СокрЛП(СоставляющиеАдреса[6]);
	КонецЕсли;

	Если СокрЛП(СоставляющиеАдреса[7]) <> "" Тогда
		ТекПредставление = ТекПредставление + ", " + ТипДома + " № " + СокрЛП(СоставляющиеАдреса[7]);
	КонецЕсли;

	Если СокрЛП(СоставляющиеАдреса[8]) <> "" Тогда
		ТекПредставление = ТекПредставление + ", " + ТипКорпуса + " " + СокрЛП(СоставляющиеАдреса[8]);
	КонецЕсли;

	Если СокрЛП(СоставляющиеАдреса[9]) <> "" Тогда
		ТекПредставление = ТекПредставление + ", " + ТипКвартиры + " " + СокрЛП(СоставляющиеАдреса[9]);
	КонецЕсли;

	Если СтрДлина(ТекПредставление) > 2 Тогда
		ТекПредставление = Сред(ТекПредставление, 3);
	КонецЕсли;
	
	Возврат ТекПредставление;
	
КонецФункции

&НаСервере
Функция ПолучитьНазваниеРегионаПоКоду(КодРег) 

	Если РегламентированнаяОтчетность.ПустоеЗначение(КодРег) Тогда
		Возврат "";
	КонецЕсли;

	Попытка
		КодРегЧисло = Число(КодРег);
	Исключение
		Возврат "";
	КонецПопытки;

	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	АдресныйКлассификатор.КодРегионаВКоде,
	               |	АдресныйКлассификатор.ТипАдресногоЭлемента,
	               |	АдресныйКлассификатор.Наименование,
	               |	АдресныйКлассификатор.Код
	               |ИЗ
	               |	РегистрСведений.АдресныйКлассификатор КАК АдресныйКлассификатор
	               |
	               |ГДЕ
	               |	АдресныйКлассификатор.ТипАдресногоЭлемента = &ТипАдресногоЭлемента И
	               |	АдресныйКлассификатор.КодРегионаВКоде = &КодРегионаВКоде";

	Запрос.УстановитьПараметр("КодРегионаВКоде", КодРегЧисло);
	Запрос.УстановитьПараметр("ТипАдресногоЭлемента", 1);

	Выборка = Запрос.Выполнить().Выбрать();

	Если Выборка.Количество() > 0 Тогда
		
		Выборка.Следующий();
		Возврат УправлениеКонтактнойИнформацией.ПолучитьПолноеНазвание(Выборка.Код);
		
	Иначе

		Возврат "";

	КонецЕсли;

КонецФункции // ПолучитьНазваниеРегионаПоКоду


&НаКлиенте
Процедура Отмена(Команда)
	Закрыть();
КонецПроцедуры

