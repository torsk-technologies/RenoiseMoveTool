local song = nil
function moveNote(direction, song)
    if song == nil then song = renoise.song() end
    local pattern_index = song.selected_pattern_index
    local track_index = song.selected_track_index
    local line_index = song.selected_line_index

    local thisNote = getNoteAtCursor(song, line_index, track_index, pattern_index)
    if not thisNote then
        return
    end

    local index, otherNote = findNextLineWithEmptyNote(song, line_index, direction, track_index, pattern_index)
    if not otherNote then
        return
    else
        otherNote:copy_from(thisNote)
        thisNote:clear()
        song.selected_line_index = line_index + direction * index
    end

end

function getNoteAtCursor(song, line_index, track_index, pattern_index)
    return
        song.patterns[pattern_index].tracks[track_index].lines[line_index].note_columns[song.selected_note_column_index]
end

function findNextLineWithEmptyNote(song, line_index, direction, track_index, pattern_index)
    local note
    local noteIsEmpty = false
    local index = 1
    while not noteIsEmpty do
        local lineIndex = line_index + direction * index
        if lineIndex < 1 or lineIndex > song.selected_pattern.number_of_lines then
            -- Stop searching if we've reached the end of the pattern
            break
        end
        note =
            song.patterns[pattern_index].tracks[track_index].lines[lineIndex].note_columns[song.selected_note_column_index]
        noteIsEmpty = note.is_empty
        index = index + 1
    end
    index = index - 1
    if not note then
        return nil
    end
    return index, note
end

renoise.tool():add_keybinding{
    name = "Pattern Editor:Tools:Move note down",
    invoke = function()
        moveNote(1, song)
    end
}

renoise.tool():add_keybinding{
    name = "Pattern Editor:Tools:Move note up",
    invoke = function()
        moveNote(-1, song)
    end
}
