﻿
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// При групповом перепроведении реквизиты документов не меняются,
	// поэтому обновление связанных данных выполнять не требуется.
	Если ПроведениеСервер.ГрупповоеПерепроведение(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаОписания = Новый ТаблицаЗначений;
	ТаблицаОписания.Колонки.Добавить("Наименование");
	ТаблицаОписания.Колонки.Добавить("Количество"  );
	
	Для Каждого СтрокаЗаказа Из Товары Цикл
		
		Если ПустаяСтрока(СтрокаЗаказа.ИдентификаторСтроки) Тогда
			СтрокаЗаказа.ИдентификаторСтроки = Новый УникальныйИдентификатор;
		КонецЕсли;
		
		Если Не СтрокаЗаказа.Номенклатура.Пустая() Тогда
			СтрокаОписания = ТаблицаОписания.Добавить();
			СтрокаОписания.Наименование = Лев(СтрокаЗаказа.Номенклатура, Найти(Строка(СтрокаЗаказа.Номенклатура)+" ", " ")-1);
			СтрокаОписания.Количество   = 1;
		КонецЕсли;
		
	КонецЦикла;
	
	ТаблицаОписания.Свернуть("Наименование", "Количество");
	
	Для Каждого СтрокаОписания Из ТаблицаОписания Цикл
		Если СтрокаОписания.Количество > 1 Тогда
			СтрокаОписания.Наименование = СтрокаОписания.Наименование+" ("+СтрокаОписания.Количество+")";
		КонецЕсли;
	КонецЦикла;
	
	КраткийСоставДокумента = СтрСоединить(ТаблицаОписания.ВыгрузитьКолонку("Наименование"), "; ");
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ЗаявкаТовары.Ссылка.Дата КАК Период,
	|	ЗаявкаТовары.ИдентификаторСтроки КАК ИдентификаторСтроки,
	|	СтатусыЗаявки.Ссылка КАК Статус,
	|	ЗаявкаТовары.Ссылка.Ответственный КАК Ответственный,
	|	&ИмяКомпьютера КАК ИмяКомпьютера,
	|	ЗаявкаТовары.Комментарий КАК Комментарий
	|ИЗ
	|	Документ.Заявка.Товары КАК ЗаявкаТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаСтатусы КАК ЗаявкаСтатусы
	|		ПО ЗаявкаТовары.ИдентификаторСтроки = ЗаявкаСтатусы.ИдентификаторСтроки,
	|	Справочник.СтатусыЗаявки КАК СтатусыЗаявки
	|ГДЕ
	|	ЗаявкаТовары.Ссылка = &Ссылка
	|	И СтатусыЗаявки.Код = ""001""
	|	И ЗаявкаСтатусы.ИдентификаторСтроки ЕСТЬ NULL"
	);
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("ИмяКомпьютера", ИмяКомпьютера());
	
	Результат = Запрос.Выполнить();
	Если Не Результат.Пустой() Тогда
		
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			МенеджерЗаписи = РегистрыСведений.ЗаявкаСтатусы.СоздатьМенеджерЗаписи();
			ЗаполнитьЗначенияСвойств(МенеджерЗаписи, Выборка);
			МенеджерЗаписи.Записать();
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	ЗаполнитьОбъектПоУмолчанию();
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	ЗаполнитьОбъектПоУмолчанию();
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЗаявкаТовары.Номенклатура КАК Номенклатура,
	|	ВЫБОР
	|		КОГДА НЕ ЕСТЬNULL(ДопРеквизитыНоменклатуры.ЭтоЮралс, ЛОЖЬ)
	|			ТОГДА 3
	|		КОГДА НЕ ЗаявкаОферты.Номенклатура ЕСТЬ NULL
	|			ТОГДА 2
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК Перечень
	|ПОМЕСТИТЬ ПереченьНоменклатуры
	|ИЗ
	|	Документ.Заявка.Товары КАК ЗаявкаТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗаявкаПереченьОферт.СрезПоследних(НАЧАЛОПЕРИОДА(&Период, МЕСЯЦ)) КАК ЗаявкаОферты
	|		ПО (ЗаявкаТовары.Номенклатура = ЗаявкаОферты.Номенклатура)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДопРеквизитыНоменклатуры КАК ДопРеквизитыНоменклатуры
	|		ПО (ЗаявкаТовары.Номенклатура = ДопРеквизитыНоменклатуры.Номенклатура)
	|ГДЕ
	|	ЗаявкаТовары.Ссылка = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаявкаТовары.Артикул КАК Артикул,
	|	ЗаявкаТовары.Номенклатура КАК Номенклатура,
	|	ЗаявкаТовары.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ЗаявкаТовары.Количество КАК Количество,
	|	ЗаявкаТовары.ОсновноеСредство КАК ОсновноеСредство,
	|	ЗаявкаТовары.Комментарий КАК Комментарий,
	|	ЗаявкаТовары.ИдентификаторСтроки КАК ИдентификаторСтроки,
	|	ЗаявкаТовары.Приоритет КАК Приоритет,
	|	ЗаявкаТовары.Ссылка.АдресПоставки КАК АдресПоставки,
	|	ЗаявкаТовары.Ссылка.СрокПоставки КАК СрокПоставки,
	|	ЗаявкаТовары.Ссылка.Номер КАК НомерЗаявки,
	|	ЗаявкаТовары.Ссылка.Ответственный КАК Ответственный,
	|	ЗаявкаТовары.Ссылка.Организация КАК Организация,
	|	ПереченьНоменклатуры.Перечень КАК Перечень
	|ИЗ
	|	Документ.Заявка.Товары КАК ЗаявкаТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПереченьНоменклатуры КАК ПереченьНоменклатуры
	|		ПО (ЗаявкаТовары.Номенклатура = ПереченьНоменклатуры.Номенклатура)
	|ГДЕ
	|	ЗаявкаТовары.Ссылка = &Ссылка"
	);
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Период", ТекущаяДата());
	
	НаборЗаписей = Движения.ЗаявкаСтроки;
	НаборЗаписей.Загрузить(Запрос.Выполнить().Выгрузить());
	НаборЗаписей.Записать();
	
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область ОбработкаЗаполнения

Процедура ЗаполнитьОбъектПоУмолчанию()

	ОсновнаяОрганизация = БухгалтерскийУчетПереопределяемый.ПолучитьЗначениеПоУмолчанию("ОсновнаяОрганизация");
	Справочники.Организации.ПроверитьНаличиеОрганизацииПриОднофирменномУчете(ОсновнаяОрганизация);
	
	Организация   = ОсновнаяОрганизация;
	Дата          = ТекущаяДатаСеанса();
	СрокПоставки  = Неопределено;
	Ответственный = Пользователи.ТекущийПользователь();
	
	Для Каждого СтрокаЗаказа Из Товары Цикл
		СтрокаЗаказа.ИдентификаторСтроки = Новый УникальныйИдентификатор;		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти // ОбработкаЗаполнения

#КонецОбласти // СлужебныеПроцедурыИФункции

#КонецЕсли