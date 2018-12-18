////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаКлиенте
// Процедура запускает сервисные функции необходимые для создания вопроса
//
Процедура СоздатьВопрос(Команда)
	
	Если Не ЭтаФорма.ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли; 
	
	СообщениеТекст = ТекстВопроса.ПолучитьТекст();
	Если СообщениеТекст = "" Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = НСтр("ru = 'Не заполнен текст вопроса!'; en = 'Not full text of the request!'");
		Сообщение.Поле = "ТекстВопроса";
		Сообщение.Сообщить(); 
		Возврат;
	КонецЕсли; 
  	Если ТаблицаПрикрепленныхФайлов.Количество()>0 Тогда
		Состояние(НСтр("ru = 'Передача информации на сервер..'; en = 'Transmission of information to the server ..'"));
	КонецЕсли;
	Результат = СоздатьНовыйВопросНаСервере();
	Если Результат <> "true" Тогда
		Структура = Новый Структура;
		Структура.Вставить("ТекстПредупреждения",Результат);
		
		// { RGS Лунякин Иван 27.10.2015 13:43:40 
		Структура.Вставить("Администратор", Администратор);
    	// } RGS Лунякин Иван 27.10.2015 13:43:40
		
		Попытка
			ОткрытьФорму("ВнешняяОбработка.rgsМониторСопровождения.Форма.ФормаПредупреждения", Структура, ЭтаФорма, ,ВариантОткрытияОкна.ОтдельноеОкно);
		Исключение
			ОткрытьФорму("Обработка.rgsМониторСопровождения.Форма.ФормаПредупреждения", Структура, ЭтаФорма, ,ВариантОткрытияОкна.ОтдельноеОкно);
		КонецПопытки; 
		
		Возврат;
		
	Иначе
		ПоказатьОповещениеПользователя(, , Символы.ПС+НСтр("ru = 'Вопрос успешно создан'; en = 'Request successfully created'"));
		Оповестить("НужноОбновитьСписокВопросов", , ЭтаФорма);
		ЭтаФорма.Закрыть();
   	КонецЕсли; 
		
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	Закрыть();
	
КонецПроцедуры

&НаСервере
// Процедура запускает сервисные функции необходимые для создания вопроса
//
Функция СоздатьНовыйВопросНаСервере()
		
	Попытка
		ДанныеДляВопроса = СобратьДанныеОВопросе();
		Определение = Новый WSОпределения(Объект.АдресБазы+"/ws/MonitorExt.1cws?wsdl", Объект.Пользователь, Объект.Пароль);
		Прокси = ПолучитьПрокси(Определение);
		Прокси.Пользователь = Объект.Пользователь;
		Прокси.Пароль = Объект.Пароль; 
		Результат = Прокси.СоздатьНовыйВопрос(ДанныеДляВопроса);
		Возврат Результат;
	Исключение
		Возврат ОписаниеОшибки();
	КонецПопытки; 

КонецФункции

&НаСервере
Функция СобратьДанныеОВопросе()
	
	СообщениеХТМЛ = "";
	СтруктураКартинок = Новый Структура;
	ТекстВопроса.ПолучитьHTML(СообщениеХТМЛ, СтруктураКартинок);
	Для Каждого ЭлСтруктуры Из СтруктураКартинок Цикл
		BASE64 = ПолучитьBASE64ПредставлениеКартинки(ЭлСтруктуры.Значение);
		СообщениеХТМЛ = СтрЗаменить(СообщениеХТМЛ, ЭлСтруктуры.Ключ, "data:image;base64,"+BASE64+"");  
	КонецЦикла;
	
	СообщениеТекст = ТекстВопроса.ПолучитьТекст();

	СтруктураДанных = Новый Структура;
	СтруктураДанных.Вставить("ТемаВопроса", ТемаВопроса);
	СтруктураДанных.Вставить("СообщениеХТМЛ", СообщениеХТМЛ);
	СтруктураДанных.Вставить("СообщениеТекст", СообщениеТекст);
	СтруктураДанных.Вставить("ГУИДПроекта", ГУИДПроекта);
	СтруктураДанных.Вставить("ДатаВопроса", ДатаВопроса);
	СтруктураДанных.Вставить("Приоритет", Приоритет);
	Если Найти(ОтКого, ";") = 0 Тогда
		СтруктураДанных.Вставить("АвторВопроса",ОтКого);//Автор один
	КонецЕсли;
	СтруктураДанных.Вставить("ТребуемаяДатаОтвета", ТребуемаяДатаОтвета);
	СтруктураДанных.Вставить("ТаблицаУчастников", УчастникиОбсуждения.Выгрузить());
	Если ТаблицаПрикрепленныхФайлов.Количество()>0 Тогда
		МассивВложений = Новый Массив;
		Для Каждого ЭлементВложений Из ТаблицаПрикрепленныхФайлов Цикл
			СтруктураВложения = Новый Структура;
           	ДвоичныеДанные =  ПолучитьИзВременногоХранилища(ЭлементВложений.АдресВоВременномХранилище);
			СтруктураВложения.Вставить("Размер", ДвоичныеДанные.Размер());
			СтруктураВложения.Вставить("Расширение", ЭлементВложений.Расширение);
			СтруктураВложения.Вставить("ИмяБезРасширения", ЭлементВложений.ИмяБезРасширения);
			СтруктураВложения.Вставить("ДвоичныеДанные", ДвоичныеДанные);
			МассивВложений.Добавить(СтруктураВложения);			
		КонецЦикла; 
		СтруктураДанных.Вставить("МассивВложений", МассивВложений);
	КонецЕсли; 

	СтруктураДанныхСтрокой = ЗначениеВСтрокуВнутр(СтруктураДанных);
	Возврат СтруктураДанныхСтрокой;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьBASE64ПредставлениеКартинки(Картинка)
	
	Возврат Base64Строка(Картинка.ПолучитьДвоичныеДанные());
	
КонецФункции

&НаСервере
Процедура ЗагрузитьТаблицу(ТаблицаПользователейВр)
	
	УчастникиОбсуждения.Загрузить(ТаблицаПользователейВр.Выгрузить());
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСоставОбсуждающихПоУмолчанию(ГУИДПроекта)
	
	Попытка
		Определение = Новый WSОпределения(Объект.АдресБазы+"/ws/MonitorExt.1cws?wsdl", Объект.Пользователь, Объект.Пароль);
		Прокси = ПолучитьПрокси(Определение);
		Прокси.Пользователь = Объект.Пользователь;
		Прокси.Пароль = Объект.Пароль;
		
		СтрутураДанных = ЗначениеИзСтрокиВнутр(Прокси.СоставОбсуждающихПоУмолчанию(ГУИДПроекта));
		УчастникиОбсуждения.Загрузить(СтрутураДанных.ТаблицаПользователей);
		УдалитьДублиТекПользователя();
		ТребуемаяДатаОтвета = ДатаВопроса + СтрутураДанных.СрокОтвета*24*60*60;
     	НоваяСтрока = УчастникиОбсуждения.Добавить();
		НоваяСтрока.ГУИДПользователя = ГУИДТекПользователя;
		НоваяСтрока.ИмяПользователя = ИмяТекПользователя;
        НоваяСтрока.СторонаПользователя = "Спрашивающий";
	Исключение
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ОписаниеОшибки();
		Сообщение.Сообщить(); 
	КонецПопытки; 
	
КонецПроцедуры

&НаСервере
Процедура УдалитьДублиТекПользователя()
	
	Массив = УчастникиОбсуждения.НайтиСтроки(Новый Структура("ГУИДПользователя", ГУИДТекПользователя));
	Для Каждого ЭлементМассива Из Массив Цикл
		УчастникиОбсуждения.Удалить(ЭлементМассива);
	КонецЦикла; 
	
КонецПроцедуры
 
&НаСервере
Процедура ЗаполнитьТаблицуПроектов()
	
	Попытка
		Определение = Новый WSОпределения(Объект.АдресБазы+"/ws/MonitorExt.1cws?wsdl", Объект.Пользователь, Объект.Пароль);
		Прокси = ПолучитьПрокси(Определение);
		Прокси.Пользователь = Объект.Пользователь;
		Прокси.Пароль = Объект.Пароль; 
		ТаблицаПроектовПользователя.Загрузить(ЗначениеИзСтрокиВнутр(Прокси.СписокПроектовПользователя()));
		НомерСтроки = 0;
		СтрокаВыбранаАвтоматически = Ложь;
		Если НЕ ПустаяСтрока(ПроектБазы) Тогда
			СтруктураОтбора = Новый Структура("НаименованиеПроекта", ПроектБазы); 
			МассивНайденныхСтрок = ТаблицаПроектовПользователя.НайтиСтроки(СтруктураОтбора);	
			
			Если МассивНайденныхСтрок.Количество() <> 0 Тогда
				НомерСтроки = ТаблицаПроектовПользователя.Индекс(МассивНайденныхСтрок[0]);
				СтрокаВыбранаАвтоматически = Истина;
			КонецЕсли;  
			
		КонецЕсли;
		Если ТаблицаПроектовПользователя.Количество() = 1 ИЛИ СтрокаВыбранаАвтоматически Тогда
			Объект.Проект = ТаблицаПроектовПользователя[НомерСтроки].НаименованиеПроекта;
			ГУИДПроекта = ТаблицаПроектовПользователя[НомерСтроки].ГУИДПроекта;
			ДанныеФормы = РеквизитФормыВЗначение("Объект");
			Элементы.Проект.Видимость = ДанныеФормы.ВидимостьПроекта(СтрокаВыбранаАвтоматически,ПроектОдин);
			//Элементы.Проект.Видимость = ?(СтрокаВыбранаАвтоматически, Ложь, Булево(НомерСтроки)); //Если заполнен проект базы и такой проект существует скрываем проект, если не заполнен Проверяем что выбран первый проект (единственный)
		КонецЕсли;
		
		СписокПроектов = Новый Массив;
		Для Каждого Строка Из ТаблицаПроектовПользователя Цикл 
			СписокПроектов.Добавить(Строка.НаименованиеПроекта);
		КонецЦикла;
		Элементы.Проект.СписокВыбора.ЗагрузитьЗначения(СписокПроектов);

	Исключение
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ОписаниеОшибки();
		Сообщение.Сообщить(); 
	КонецПопытки; 
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьРеквизитыФормы()
	
	ОтКого.Очистить();
	Кому.Очистить();
	СторонниеНаблюдатели.Очистить();
	Для Каждого ЭлСписка Из УчастникиОбсуждения Цикл
		Если ЭлСписка.СторонаПользователя = "Спрашивающий" Тогда
			ОтКого.Добавить(ЭлСписка.ИмяПользователя);
		КонецЕсли; 
		Если ЭлСписка.СторонаПользователя = "Отвечающий" Тогда
			Кому.Добавить(ЭлСписка.ИмяПользователя);
		КонецЕсли; 
		Если ЭлСписка.СторонаПользователя = "Сторонний наблюдатель" Тогда
			СторонниеНаблюдатели.Добавить(ЭлСписка.ИмяПользователя);
		КонецЕсли; 
	КонецЦикла; 
	
КонецПроцедуры
 
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
// Процедура - обработчик события "ПриСозданииНаСервере" формы
//
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Объект.Пользователь = Параметры.Пользователь;
	Объект.Пароль		= Параметры.Пароль;
	Объект.АдресБазы 	= Параметры.АдресБазы;
	ГУИДТекПользователя = Параметры.Объект.ГУИДТекПользователя;
	ИмяТекПользователя 	= Параметры.Объект.ИмяТекПользователя;
	
	// { RGS Лунякин Иван 27.10.2015 12:47:51 
	Администратор 		= Параметры.Администратор;
	Объект.Проект 		= Параметры.ПроектБазы;
	ПроектБазы 			= Параметры.ПроектБазы;
	Элементы.ФормаИзменитьФорму.Видимость = Администратор;
	ЗаполнитьСписокВыбораПриоритета(Элементы.Приоритет.СписокВыбора);
	ПроектОдин = Параметры.ПроектОдин;
	// } RGS Лунякин Иван 27.10.2015 12:47:51
	
	// { RGS Лунякин Иван 03.11.2015 16:29:30 
	ПолучитьНастройкиФормы();
	// } RGS Лунякин Иван 03.11.2015 16:29:30
	
	ДатаВопроса			= ТекущаяДата();
	Приоритет			= НСтр("ru = 'Обычный'; en = 'Normal'");
	ЗаполнитьТаблицуПроектов();
	
	Если ГУИДПроекта<>"" Тогда
		ЗаполнитьСоставОбсуждающихПоУмолчанию(ГУИДПроекта);
	КонецЕсли; 
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаполнитьСписокВыбораПриоритета(СписокВыбора)
	СписокВыбора.Добавить(НСтр("ru = 'Критический'; en = 'Critical'"));
	СписокВыбора.Добавить(НСтр("ru = 'Высокий'; en = 'High'"));
	СписокВыбора.Добавить(НСтр("ru = 'Обычный'; en = 'Normal'"));
	СписокВыбора.Добавить(НСтр("ru = 'Низкий'; en = 'Low'"));
КонецПроцедуры
 
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ЗакрыватьПриЗакрытииВладельца = Истина;
	ЗаполнитьРеквизитыФормы();
	УстановитьРежимВыбораТемы();
КонецПроцедуры

// { RGS Глебов Дмитрий 19.09.2016 - ОРР-0003215
&НаКлиенте
Процедура УстановитьРежимВыбораТемы()
	ЕстьПредопределенныеТемы = Ложь;
	Если НЕ ПустаяСтрока(Объект.Проект) Тогда
		ЕстьПредопределенныеТемы =  ПроверитьНаличиеТемВПроекте(Объект.Проект);
	КонецЕсли;
	Если НЕ ЕстьПредопределенныеТемы Тогда
		Элементы.ТемаВопроса.ПодсказкаВвода = НСтр("ru = 'Введите тему вопроса'; en = 'Input subject of request'");
	Иначе
		Элементы.ТемаВопроса.ПодсказкаВвода = "";
	КонецЕсли;
	Элементы.ТемаВопроса.РедактированиеТекста = НЕ ЕстьПредопределенныеТемы;
	Элементы.ТемаВопроса.КнопкаВыбора = ЕстьПредопределенныеТемы;

КонецПроцедуры
// } RGS Глебов Дмитрий 19.09.2016 - ОРР-0003215

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ РЕКВИЗИТОВ ФОРМЫ И КОМАНД

 &НаКлиенте
Процедура ПроектНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)

	Элемент.СписокВыбора.Очистить();
	Для Каждого ЭлСписка Из ТаблицаПроектовПользователя Цикл
		Элемент.СписокВыбора.Добавить(ЭлСписка.НаименованиеПроекта, ЭлСписка.НаименованиеПроекта);
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура ПроектОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Массив = ТаблицаПроектовПользователя.НайтиСтроки(Новый Структура("НаименованиеПроекта", ВыбранноеЗначение));
	Если Массив.Количество()>0 Тогда
		ГУИДПроекта = Массив[0].ГУИДПроекта;
	КонецЕсли; 
		
КонецПроцедуры

&НаКлиенте
Процедура ПроектПриИзменении(Элемент)
	
	ПроектДо = Проект;
	Если ПроектДо<>Объект.Проект Тогда
		ЗаполнитьСоставОбсуждающихПоУмолчанию(ГУИДПроекта);
		ЗаполнитьРеквизитыФормы();
	КонецЕсли; 
	Проект = Объект.Проект;
	
	// { RGS Лунякин Иван 07.10.2015 15:04:18 
	Если НЕ ПроверитьНаличиеТемВПроекте(Проект) Тогда 
		Элементы.ТемаВопроса.ПодсказкаВвода = НСтр("ru = 'Введите тему вопроса'; en = 'Input subject of request'");
		Элементы.ТемаВопроса.РедактированиеТекста = Истина;
	Иначе
		ТемаВопроса = "";
		Элементы.ТемаВопроса.ПодсказкаВвода = "";
		Элементы.ТемаВопроса.РедактированиеТекста = Ложь;
	КонецЕсли;
	// } RGS Лунякин Иван 07.10.2015 15:04:18   
	УстановитьРежимВыбораТемы();
КонецПроцедуры

&НаКлиенте
Процедура СоставОбсуждающих(Команда)
	
	Если Не ЗначениеЗаполнено(Объект.Проект) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не заполнен проект!";
		Сообщение.Поле = "Объект.Проект";
		Сообщение.Сообщить(); 
		Возврат;
	КонецЕсли; 
	СтруктураДанных = Новый Структура;
	СтруктураДанных.Вставить("ГУИДПроекта", ГУИДПроекта);
	СтруктураДанных.Вставить("Объект", Объект);
	СтруктураДанных.Вставить("УчастникиОбсуждения", УчастникиОбсуждения);
	СтруктураДанных.Вставить("ИмяСобытия", "ОбсуждающиеНовогоВопроса");
	
	// { RGS Лунякин Иван 27.10.2015 13:43:40 
	СтруктураДанных.Вставить("Администратор", Администратор);
    // } RGS Лунякин Иван 27.10.2015 13:43:40
	
	Попытка
		ОткрытьФорму("ВнешняяОбработка.rgsМониторСопровождения.Форма.ФормаОбсуждающие", СтруктураДанных, ЭтаФорма);
	Исключение
	    ОткрытьФорму("Обработка.rgsМониторСопровождения.Форма.ФормаОбсуждающие", СтруктураДанных, ЭтаФорма);
	КонецПопытки; 
	
КонецПроцедуры


&НаКлиенте
Процедура ПроверитьОрфографию(Команда)
	
	ТекстДляПроверки = ТекстВопроса.ПолучитьТекст();
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ТекстДляПроверки", ТекстДляПроверки);
	СтруктураПараметров.Вставить("ИмяСобытия", "ПроверкаОрфографииНовогоСообщения");
	// { RGS Лунякин Иван 27.10.2015 13:43:40 
	СтруктураПараметров.Вставить("Администратор", Администратор);
    // } RGS Лунякин Иван 27.10.2015 13:43:40
	
	ТекстХТМЛ = Неопределено;
	Попытка
		ОткрытьФорму("ВнешняяОбработка.rgsМониторСопровождения.Форма.ФормаПроверкиОрфографии", СтруктураПараметров, ЭтаФорма);
	Исключение
		ОткрытьФорму("Обработка.rgsМониторСопровождения.Форма.ФормаПроверкиОрфографии", СтруктураПараметров, ЭтаФорма);
	КонецПопытки; 
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПравильноеХТМЛ(ТекстХТМЛ)
	
	ТекстВопроса.УстановитьHTML(ТекстХТМЛ, Новый Структура);
	
КонецПроцедуры

&НаКлиенте
Процедура ПрикрепитьФайлы(Команда)
	
	СтруктураДанных = Новый Структура;
	СтруктураДанных.Вставить("ТаблицаПрикрепленныхФайлов", ТаблицаПрикрепленныхФайлов);
	СтруктураДанных.Вставить("ИмяСобытия", "ФормаНовогоВопроса");
	// { RGS Лунякин Иван 27.10.2015 13:43:40 
	СтруктураДанных.Вставить("Администратор", Администратор);
    // } RGS Лунякин Иван 27.10.2015 13:43:40
	
	Попытка
		ОткрытьФорму("ВнешняяОбработка.rgsМониторСопровождения.Форма.ФормаПрисоединенныхФайлов", СтруктураДанных, ЭтаФорма);
	Исключение
	    ОткрытьФорму("Обработка.rgsМониторСопровождения.Форма.ФормаПрисоединенныхФайлов", СтруктураДанных, ЭтаФорма);
	КонецПопытки;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьПрокси(Определение) Экспорт
	
	Возврат Новый WSПрокси (Определение, "RemoteConnect", "RemoteConnect", "RemoteConnectSoap");
	
КонецФункции


&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ПрикрепилиФайлыФормаНовогоВопроса" Тогда
		Если Параметр <> Неопределено  Тогда
			ТаблицаПрикрепленныхФайлов.Очистить();
			Для Каждого Строка Из Параметр Цикл
				НоваяСтрока = ТаблицаПрикрепленныхФайлов.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
			КонецЦикла; 
		КонецЕсли;
	ИначеЕсли ИмяСобытия = "ПроверкаОрфографииНовогоСообщения" Тогда
		Если Параметр <> Неопределено Тогда
			УстановитьПравильноеХТМЛ(Параметр);
		КонецЕсли;
	ИначеЕсли ИмяСобытия = "ОбсуждающиеНовогоВопроса" Тогда
		Если Параметр <> Неопределено Тогда
			ЗагрузитьТаблицу(Параметр);
			ЗаполнитьРеквизитыФормы();
		КонецЕсли;
	// { RGS Лунякин Иван 07.10.2015 13:53:17 	
	ИначеЕсли ИмяСобытия = "ОбработкаВыбора" Тогда
		  ОбработкаВыбора(Параметр);
	// } RGS Лунякин Иван 07.10.2015 13:53:17   
	КонецЕсли;
	
КонецПроцедуры

// { RGS Лунякин Иван 06.10.2015 10:41:39 
&НаКлиенте
Процедура ТемаВопросаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)  
	Если НЕ ПустаяСтрока(Объект.Проект) Тогда
		Если НЕ ПроверитьНаличиеТемВПроекте(Объект.Проект) Тогда
			ТемаВопроса = "";
			Элементы.ТемаВопроса.ПодсказкаВвода = НСтр("ru = 'Введите тему вопроса'; en = 'Input subject of request'");
			Элементы.ТемаВопроса.РедактированиеТекста = Истина;	
		Иначе
			
			// { RGS Лунякин Иван 27.10.2015 13:43:40 
			Структура = Новый Структура();
			Структура.Вставить("Администратор", Администратор);
			Структура.Вставить("Проект", Объект.Проект);
    		// } RGS Лунякин Иван 27.10.2015 13:43:40
			
			Попытка
				ОткрытьФорму("ВнешняяОбработка.rgsМониторСопровождения.Форма.ФормаВыбораТемыНовогоВопроса", Структура, ЭтаФорма,,ВариантОткрытияОкна.ОтдельноеОкно);
			Исключение
				Сообщить(ОписаниеОшибки());
				ОткрытьФорму("Обработка.rgsМониторСопровождения.Форма.ФормаВыбораТемыНовогоВопроса", Структура, ЭтаФорма,,ВариантОткрытияОкна.ОтдельноеОкно);
			КонецПопытки;	
		КонецЕсли;
	КонецЕсли; 	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(Параметр, ДополнительныеПараметры = Неопределено) Экспорт

	РезультатЗакрытия = Неопределено;
	Если Параметр.Свойство("РезультатЗакрытия", РезультатЗакрытия) И НЕ РезультатЗакрытия = "Other" Тогда
		УстановитьТекстТемы(РезультатЗакрытия, Истина);
	Иначе
		Тема = "";
		ПоказатьВводСтроки(Новый ОписаниеОповещения("ПродолжитьВводТемы", ЭтаФорма) , Тема, НСтр("ru = 'Введите тему вопроса'; en = 'Input request'") ,,Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьТекстТемы(Текст, ТемаИзСписка);
	ТемаВопроса = Текст;
	Элементы.ТемаВопроса.РедактированиеТекста = НЕ ТемаИзСписка;
	Элементы.ТемаВопроса.ПодсказкаВвода = ?(ТемаИзСписка, "", НСтр("ru = 'Введите тему вопроса'; en = 'Input request'"));
КонецПроцедуры
	
&НаКлиенте
Процедура ПродолжитьВводТемы(Текст, ДополнительныеПараметры) Экспорт
	УстановитьТекстТемы(Текст, Ложь)
КонецПроцедуры

&НаСервере
Функция ПроверитьНаличиеТемВПроекте(Проект)

	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	Возврат ОбработкаОбъект.ПроверитьНаличиеТемВПроекте(Проект);
	
КонецФункции // ()

&НаСервере
Процедура ПолучитьНастройкиФормы()

	СтруктураНастроекФормы = ХранилищеНастроекДанныхФорм.Загрузить(ЭтаФорма.ИмяФормы, "НастройкаФорм");
	Если СтруктураНастроекФормы <> Неопределено Тогда
	   ХранилищеСистемныхНастроек.Сохранить(ЭтаФорма.ИмяФормы + "/НастройкиФормы",,СтруктураНастроекФормы);
	КонецЕсли;
	СтруктураНастроекОкна = ХранилищеНастроекДанныхФорм.Загрузить(ЭтаФорма.ИмяФормы, "НастройкаОкна");
	Если СтруктураНастроекФормы <> Неопределено Тогда
	   ХранилищеСистемныхНастроек.Сохранить(ЭтаФорма.ИмяФормы + "/НастройкиОкна",,СтруктураНастроекОкна);
	КонецЕсли;

КонецПроцедуры

// } RGS Лунякин Иван 06.10.2015 10:41:39   

// { RGS Глебов Дмитрий 20.09.2016 - ОРР-0003215
&НаКлиенте
Процедура ОтКогоНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	СоставОбсуждающих(Неопределено);	
КонецПроцедуры

&НаКлиенте
Процедура КомуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	СоставОбсуждающих(Неопределено);
КонецПроцедуры

&НаКлиенте
Процедура СторонниеНаблюдателиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	СоставОбсуждающих(Неопределено);
КонецПроцедуры
// } RGS Глебов Дмитрий 20.09.2016  - ОРР-0003215


 