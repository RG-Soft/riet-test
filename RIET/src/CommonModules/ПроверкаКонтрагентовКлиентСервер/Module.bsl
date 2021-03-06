////////////////////////////////////////////////////////////////////////////////
// Проверка одного или нескольких контрагентов при помощи веб-сервиса ФНС
//  
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

Функция ЭтоСостояниеДействующегоКонтрагента(Состояние, ДополнятьСостояниемСОшибкой = Истина, ДополнятьПустымСостоянием = Истина) Экспорт
	
	СостоянияДействующегоКонтрагента = СостоянияДействующегоКонтрагента(ДополнятьСостояниемСОшибкой, ДополнятьПустымСостоянием);
	Возврат СостоянияДействующегоКонтрагента.Найти(Состояние) <> Неопределено;
			
КонецФункции

Функция СостоянияДействующегоКонтрагента(ДополнятьСостояниемСОшибкой = Истина, ДополнятьПустымСостоянием = Истина) Экспорт
	
	МассивСостояний = Новый Массив;
	МассивСостояний.Добавить(ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.Действует"));
	МассивСостояний.Добавить(ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.НеПодлежитПроверке"));
	ДобавитьДополнительныеСостояния(МассивСостояний, ДополнятьСостояниемСОшибкой, ДополнятьПустымСостоянием);
	
	Возврат МассивСостояний;
			
КонецФункции

Функция ЭтоСостояниеНедействующегоКонтрагента(Состояние, ДополнятьСостояниемСОшибкой = Ложь, ДополнятьПустымСостоянием = Ложь) Экспорт
	
	СостоянияНедействующегоКонтрагента = СостоянияНедействующегоКонтрагента(ДополнятьСостояниемСОшибкой, ДополнятьПустымСостоянием);
	Возврат СостоянияНедействующегоКонтрагента.Найти(Состояние) <> Неопределено;
			
КонецФункции
		
Функция СостоянияНедействующегоКонтрагента(ДополнятьСостояниемСОшибкой = Ложь, ДополнятьПустымСостоянием = Ложь) Экспорт
	
	МассивСостояний = Новый Массив;
	МассивСостояний.Добавить(ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.КППНеСоотвествуетИНН"));
	МассивСостояний.Добавить(ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.ОтсутствуетВРеестре"));
	МассивСостояний.Добавить(ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.ПрекратилДеятельность"));
	ДобавитьДополнительныеСостояния(МассивСостояний, ДополнятьСостояниемСОшибкой, ДополнятьПустымСостоянием);
	
	Возврат МассивСостояний;
			
КонецФункции

Функция СсылкаНаИнструкцию() Экспорт
	Возврат Новый ФорматированнаяСтрока(ВернутьСтр("ru = 'Подробнее о проверке'"),,,,"e1cib/app/Обработка.ИнструкцияПоИспользованиюПроверкиКонтрагента");
КонецФункции

Процедура УстановитьТекстПодсказкиВДокументе(ПараметрыПрорисовки, СостояниеПроверки) Экспорт
	
	// Определение цвета и текста
	ПодсказкаВДокументе = ПодсказкаВДокументе(ПараметрыПрорисовки, СостояниеПроверки);
	
	// Цвет рамки
	ЭлементРодитель	= ПараметрыПрорисовки.ЭлементРодитель;
	ЭлементРодитель.ЦветФона = ПодсказкаВДокументе.ЦветФона;
	
	// Текст расширенной подсказки
	Элемент = ПараметрыПрорисовки.Элемент;
	Элемент.РасширеннаяПодсказка.Заголовок = ПодсказкаВДокументе.Текст;
	Элемент.ОтображениеПодсказки = ОтображениеПодсказки.Кнопка;
		
КонецПроцедуры

Процедура СменитьВидПанелиПроверкиКонтрагента(Форма, ВидПанелиПроверки = "") Экспорт
	
	Если Форма.ИспользованиеПроверкиВозможно Тогда
		
		Если ЗначениеЗаполнено(ВидПанелиПроверки) Тогда 
			
			Форма.Элементы.ПроверкаКонтрагента.Видимость = Истина;
			Форма.Элементы.ПроверкаКонтрагента.ТекущаяСтраница = Форма.Элементы[ВидПанелиПроверки];
			
			Если ВидПанелиПроверки = "НайденыНекорректныеКонтрагенты" Тогда
				
				Форма.ПереключательРежимаОтображения = ?(Форма.ВыведеныВсеСтроки, "Все", "Недействующие");
				
			КонецЕсли;
			
		Иначе
			
			Форма.Элементы.ПроверкаКонтрагента.Видимость = Ложь;
			
		КонецЕсли;
		
	Иначе
		Форма.Элементы.ПроверкаКонтрагента.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

Функция ЭтоДокументСКонтрагентомВШапке(Форма) Экспорт
	
	КонтрагентНаходитсяВШапке = Ложь;
	ПроверкаКонтрагентовКлиентСерверПереопределяемый.ОпределитьВидДокумента(Форма, КонтрагентНаходитсяВШапке);
	
	Возврат КонтрагентНаходитсяВШапке;

КонецФункции

Функция ЭтоСчетФактура(Форма) Экспорт	
	
	ЯвляетсяСчетомФактурой = Ложь;
	ПроверкаКонтрагентовКлиентСерверПереопределяемый.ОпределитьВидДокумента(Форма,,,,ЯвляетсяСчетомФактурой);
	
	Возврат ЯвляетсяСчетомФактурой;

КонецФункции

Функция ЭтоДокументСоСчетомФактуройВПодвале(Форма) Экспорт
	
	СчетФактураНаходитсяВПодвале = Ложь;
	ПроверкаКонтрагентовКлиентСерверПереопределяемый.ОпределитьВидДокумента(Форма,,,СчетФактураНаходитсяВПодвале);
	
	Возврат СчетФактураНаходитсяВПодвале;

КонецФункции

Функция ЭтоДокументСКонтрагентомВТабличнойЧасти(Форма) Экспорт
	
	КонтрагентНаходитсяВТабличнойЧасти = Ложь;
	ПроверкаКонтрагентовКлиентСерверПереопределяемый.ОпределитьВидДокумента(Форма,,КонтрагентНаходитсяВТабличнойЧасти);
	
	Возврат КонтрагентНаходитсяВТабличнойЧасти;

КонецФункции

Функция ИмяПоляКартинки(ТаблицаФормы) Экспорт
	Возврат ТаблицаФормы.Имя + "ЭтоНекорректныйКонтрагент";
КонецФункции

Функция ПодсказкаВДокументе(ПараметрыПрорисовки, СостояниеПроверки) Экспорт
	
	ДокументПустой			= ПараметрыПрорисовки.ДокументПустой;
	КонтрагентЗаполнен	 	= ПараметрыПрорисовки.КонтрагентЗаполнен;
	СостояниеКонтрагента 	= ПараметрыПрорисовки.СостояниеКонтрагента;
	КонтрагентовНесколько 	= ПараметрыПрорисовки.КонтрагентовНесколько;
	
	ЦветФона = Новый Цвет();
	Подстроки = Новый Массив;
	
	РекламаСервиса = Новый ФорматированнаяСтрока(ВернутьСтр("ru = 'В программе появилась возможность использовать веб-сервис ФНС для проверки регистрации контрагентов в ЕГРН'"));
	
	Если СостояниеПроверки = ПредопределенноеЗначение("Перечисление.СостоянияПроверкиКонтрагентов.ПроверкаНеИспользуется") 
		ИЛИ ДокументПустой Тогда
		// Выводим предложение на подключение
		Подстроки.Добавить(РекламаСервиса);
	ИначеЕсли СостояниеПроверки = ПредопределенноеЗначение("Перечисление.СостоянияПроверкиКонтрагентов.ПроверкаВПроцессе") Тогда
	    // Проверка не завершилась
		Подстроки.Добавить(Новый ФорматированнаяСтрока(ВернутьСтр("ru = 'Выполняется проверка контрагентов согласно данным ФНС'")));
													  
	ИначеЕсли СостояниеПроверки = ПредопределенноеЗначение("Перечисление.СостоянияПроверкиКонтрагентов.НетДоступаКВебСервису") Тогда
		// Нет доступа к сервису
		
		Подстроки.Добавить(Новый ФорматированнаяСтрока(ВернутьСтр("ru = 'Не удалось произвести проверку контрагентов: 
                                                      |сервис ФНС временно недоступен'")));
													  
	ИначеЕсли СостояниеПроверки = ПредопределенноеЗначение("Перечисление.СостоянияПроверкиКонтрагентов.ПроверкаВыполнена") Тогда
		// Проверка завершилась
		
		КрасныйЦвет = Новый Цвет(251, 212, 212);
		ЗеленыйЦвет = Новый Цвет(215, 240, 199);
		
		Если НЕ КонтрагентЗаполнен Тогда
			// Не заполнен контрагент
			Подстроки.Добавить(ВернутьСтр("ru = 'Проверка контрагента по базе ФНС не выполнена: не заполнен контрагент'"));
		ИначеЕсли НЕ ЗначениеЗаполнено(СостояниеКонтрагента) Тогда
			Подстроки.Добавить(РекламаСервиса);
		ИначеЕсли СостояниеКонтрагента = ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.НеПодлежитПроверке") Тогда
			// Не русский контрагент
			Подстроки.Добавить(ВернутьСтр("ru = 'Проверка контрагента по базе ФНС не выполнена: проверке подлежат только российские контрагенты'"));
		ИначеЕсли СостояниеКонтрагента = ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.ПустойИННКПП") Тогда
			// Контрагенты с пустым ИНН и КПП не проверяются
			Подстроки.Добавить(ВернутьСтр("ru = 'Проверка контрагента по базе ФНС не выполнена: не заполнен ИНН/КПП'"));
		ИначеЕсли ПроверкаКонтрагентовКлиентСервер.ЭтоСостояниеНедействующегоКонтрагента(СостояниеКонтрагента) Тогда
			// Недействующий контрагент
			Если КонтрагентовНесколько Тогда
				// Выводим обобщенно
				Подстроки.Добавить(ВернутьСтр("ru = 'Обнаружены недействующие контрагенты по данным ФНС'"));
			Иначе
				// Выводим конкретное состояние
				Подстроки.Добавить(Строка(СостояниеКонтрагента));
			КонецЕсли;
			ЦветФона = КрасныйЦвет; 
		ИначеЕсли СостояниеКонтрагента = ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.СодержитОшибкиВДанных") Тогда
			// Контрагент с ошибками в ИНН/КПП или дате
			Подстроки.Добавить(ВернутьСтр("ru = 'Проверка контрагента по базе ФНС не выполнена: обнаружены ошибки в заполнении ИНН/КПП/даты документа'"));
			ЦветФона = КрасныйЦвет;
		ИначеЕсли СостояниеКонтрагента = ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.Действует") Тогда
			// Действующий корректный контрагент
			Если КонтрагентовНесколько Тогда
				// Выводим обобщенно 
				Подстроки.Добавить(ВернутьСтр("ru = 'Проверка контрагентов по данным ФНС выполнена успешно'"));
			Иначе
				// Выводим конкретное состояние
				Подстроки.Добавить(Строка(СостояниеКонтрагента));
			КонецЕсли;
			ЦветФона = ЗеленыйЦвет;
		КонецЕсли;
		
	КонецЕсли;
	
	Подстроки.Добавить(Символы.ПС);
	Подстроки.Добавить(ПроверкаКонтрагентовКлиентСервер.СсылкаНаИнструкцию());
	
	Результат = Новый Структура;
	Результат.Вставить("Текст", 	Новый ФорматированнаяСтрока(Подстроки));
	Результат.Вставить("ЦветФона",  ЦветФона);
	
	Возврат Результат; 
		
КонецФункции

Функция СчетФактура(Форма) Экспорт
	
	СчетФактура = Неопределено;
	ПроверкаКонтрагентовКлиентСерверПереопределяемый.ПолучитьСчетФактуру(Форма, СчетФактура);
	
	Возврат СчетФактура;
	
КонецФункции

Процедура СохранитьРезультатПроверкиКонтрагентов(Форма) Экспорт
	
	Если Форма.ИспользованиеПроверкиВозможно Тогда
		
		ДокументОбъект 	= Форма.Объект;
		ДокументСсылка 	= ДокументОбъект.Ссылка; 
		
		ЭтоДокументСКонтрагентомВШапке 			= ПроверкаКонтрагентовКлиентСервер.ЭтоДокументСКонтрагентомВШапке(Форма); 
		ЭтоДокументСКонтрагентомВТабличнойЧасти = ПроверкаКонтрагентовКлиентСервер.ЭтоДокументСКонтрагентомВТабличнойЧасти(Форма);
		ЭтоДокументСоСчетомФактуройВПодвале 	= ПроверкаКонтрагентовКлиентСервер.ЭтоДокументСоСчетомФактуройВПодвале(Форма);
		ЭтоСчетФактура							= ПроверкаКонтрагентовКлиентСервер.ЭтоСчетФактура(Форма);
		
		СохраняемоеЗначение = Новый Соответствие;
		
		Если ЭтоДокументСКонтрагентомВШапке ИЛИ ЭтоДокументСКонтрагентомВТабличнойЧасти Тогда 
			// Документ-основание
			Если ЭтоДокументСКонтрагентомВТабличнойЧасти ИЛИ 
				ЕстьРеквизитФормы(Форма, "СостояниеКонтрагента") И ЗначениеЗаполнено(Форма.СостояниеКонтрагента) Тогда
				СохраняемоеЗначение.Вставить(ДокументСсылка, Форма.ЭтоДокументСОшибкой);
			КонецЕсли;
		КонецЕсли;
		
		Если ЭтоДокументСоСчетомФактуройВПодвале Тогда 
			// Счет-фактура
			СчетФактура = ПроверкаКонтрагентовКлиентСервер.СчетФактура(Форма);
			Если ЗначениеЗаполнено(СчетФактура) И ЗначениеЗаполнено(Форма.СостояниеКонтрагентовВСчетеФактуре) Тогда
				СохраняемоеЗначение.Вставить(СчетФактура, Форма.ЭтоСчетФактураСОшибкой);
			КонецЕсли;
		КонецЕсли;
		
		Если ЭтоСчетФактура Тогда 
			Если ЗначениеЗаполнено(Форма.СостояниеКонтрагентов) Тогда
				СохраняемоеЗначение.Вставить(ДокументСсылка, Форма.ЭтоСчетФактураСОшибкой);
			КонецЕсли;
		КонецЕсли;
		
		ПроверкаКонтрагентовВызовСервера.СохранитьРезультатыПроверкиКонтрагентовВДокументеВРегистр(СохраняемоеЗначение);
			
	КонецЕсли;
	
КонецПроцедуры

Функция ЕстьРеквизитФормы(Форма, ИмяРеквизита) Экспорт
	
	ИскомыеРеквизиты = Новый Структура(ИмяРеквизита, NULL);
	ЗаполнитьЗначенияСвойств(ИскомыеРеквизиты, Форма);

	РеквизитСуществует = Ложь;
	Если ИскомыеРеквизиты[ИмяРеквизита] <> NULL Тогда
		РеквизитСуществует = Истина;
	КонецЕсли;
	
	Возврат РеквизитСуществует;

КонецФункции

#КонецОбласти

#Область ВспомогательныеПроцедурыИФункции

Процедура ДобавитьДополнительныеСостояния(МассивСостояний, ДополнятьСостояниемСОшибкой, ДополнятьПустымСостоянием)
	
	Если ДополнятьСостояниемСОшибкой Тогда
		МассивСостояний.Добавить(ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.СодержитОшибкиВДанных"));
	КонецЕсли;
	Если ДополнятьПустымСостоянием Тогда
		МассивСостояний.Добавить(ПредопределенноеЗначение("Перечисление.СостоянияСуществованияКонтрагента.ПустаяСсылка"));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти