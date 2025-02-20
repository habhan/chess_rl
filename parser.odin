package chess

import "core:fmt"
import "core:os"
import "core:strings"

//NOTE:
// Plan:
// 1. Import the file
// 2. Read the file
// 3. Create moves out of content of file
// 4. ??

//INFO: A complete pgn of a game

/* 
[Event "Rated blitz game"]
[Site "https://lichess.org/CNFTCpv2"]
[Date "2025.01.16"]
[White "ad_lib"]
[Black "BlunderfulPlay"]
[Result "0-1"]
[UTCDate "2025.01.16"]
[UTCTime "13:08:22"]
[WhiteElo "779"]
[BlackElo "896"]
[WhiteRatingDiff "-21"]
[BlackRatingDiff "+27"]
[Variant "Standard"]
[TimeControl "300+3"]
[ECO "B01"]
[Opening "Scandinavian Defense: Main Line"]
[Termination "Time forfeit"]
[Annotator "lichess.org"]

1. e4 { [%clk 0:05:00] } 1... d5 { [%clk 0:05:00] } 2. exd5 { [%clk 0:04:58] } 2... Qxd5 { [%clk 0:05:02] } 3. Nc3 { [%clk 0:05:00] } 3... Qa5 { [%clk 0:05:03] } { B01 Scandinavian Defense: Main Line } 4. d4 { [%clk 0:04:55] } 4... c6 { [%clk 0:05:03] } 5. Bd2 { [%clk 0:04:43] } 5... e6 { [%clk 0:05:04] } 6. Nf3 { [%clk 0:04:45] } 6... Be7 { [%clk 0:04:52] } 7. Ne4 { [%clk 0:04:37] } 7... Qc7 { [%clk 0:04:52] } 8. Bc4 { [%clk 0:04:18] } 8... Nf6 { [%clk 0:04:51] } 9. Nfg5 { [%clk 0:04:06] } 9... O-O { [%clk 0:04:35] } 10. g3 { [%clk 0:03:52] } 10... h6 { [%clk 0:04:20] } 11. Nxf6+ { [%clk 0:03:42] } 11... Bxf6 { [%clk 0:04:19] } 12. Ne4 { [%clk 0:03:41] } 12... Bxd4 { [%clk 0:04:16] } 13. Bf4 { [%clk 0:03:40] } 13... Qb6 { [%clk 0:04:09] } 14. c3 { [%clk 0:03:27] } 14... Bc5 { [%clk 0:03:48] } 15. Qg4 { [%clk 0:03:19] } 15... Qxb2 { [%clk 0:03:41] } 16. Rd1 { [%clk 0:02:21] } 16... b5 { [%clk 0:03:01] } 17. Be5 { [%clk 0:02:13] } 17... g5 { [%clk 0:02:46] } 18. Nxc5 { [%clk 0:01:07] } 18... bxc4 { [%clk 0:02:37] } 19. a4 { [%clk 0:00:55] } 19... f6 { [%clk 0:02:13] } 20. Nxe6 { [%clk 0:00:38] } 20... Bxe6 { [%clk 0:02:07] } 21. Qxe6+ { [%clk 0:00:39] } 21... Kg7 { [%clk 0:01:59] } 22. Qe7+ { [%clk 0:00:35] } 22... Kg8 { [%clk 0:01:56] } 23. Rd8 { [%clk 0:00:35] } 23... Qb1+ { [%clk 0:01:46] } 24. Ke2 { [%clk 0:00:34] } 24... Qc2+ { [%clk 0:01:44] } 25. Kf3 { [%clk 0:00:34] } 25... Qf5+ { [%clk 0:01:43] } 26. Kg2 { [%clk 0:00:33] } 26... Rxd8 { [%clk 0:01:29] } 27. Qxd8+ { [%clk 0:00:32] } 27... Kf7 { [%clk 0:01:30] } 28. Bxb8 { [%clk 0:00:30] } 28... Qe4+ { [%clk 0:01:23] } 29. f3 { [%clk 0:00:31] } 29... Qe2+ { [%clk 0:01:24] } 30. Kh3 { [%clk 0:00:32] } 30... Qe6+ { [%clk 0:01:21] } 31. Kg2 { [%clk 0:00:33] } 31... Qe2+ { [%clk 0:01:23] } 32. Kh3 { [%clk 0:00:34] } 32... Qe6+ { [%clk 0:01:25] } 33. g4 { [%clk 0:00:35] } 33... f5 { [%clk 0:01:17] } 34. Qc7+ { [%clk 0:00:25] } 34... Qe7 { [%clk 0:01:12] } 35. Qxe7+ { [%clk 0:00:17] } 35... Kxe7 { [%clk 0:01:14] } 36. Re1+ { [%clk 0:00:19] } 36... Kf6 { [%clk 0:01:16] } 37. Be5+ { [%clk 0:00:19] } 37... Kg6 { [%clk 0:01:16] } 38. gxf5+ { [%clk 0:00:13] } 38... Kxf5 { [%clk 0:01:18] } 39. Bg3 { [%clk 0:00:13] } 39... Rg8 { [%clk 0:01:08] } 40. Re4 { [%clk 0:00:15] } 40... h5 { [%clk 0:01:04] } 41. Rxc4 { [%clk 0:00:16] } 41... g4+ { [%clk 0:00:56] } 42. Kg2 { [%clk 0:00:17] } 42... gxf3+ { [%clk 0:00:56] } 43. Kxf3 { [%clk 0:00:18] } 43... Rg4 { [%clk 0:00:57] } 44. Rxc6 { [%clk 0:00:11] } 44... Rxa4 { [%clk 0:00:51] } 45. c4 { [%clk 0:00:10] } 45... Ra3+ { [%clk 0:00:48] } 46. Kg2 { [%clk 0:00:09] } 46... a5 { [%clk 0:00:38] } 47. Rc5+ { [%clk 0:00:09] } 47... Kg6 { [%clk 0:00:36] } 48. Be1 { [%clk 0:00:08] } 48... a4 { [%clk 0:00:35] } 49. Rc6+ { [%clk 0:00:04] } 49... Kf5 { [%clk 0:00:33] } { Black wins on time. } 0-1
*/

getPgnContent :: proc(file: string) -> []byte {
	f, err := os.open(file)
	defer os.close(f)

	if err == nil {
		c, ok := os.read_entire_file_from_handle(f)
		defer delete(c)
		return c
	} else {
		fmt.println(err)
	}

	return {}
}

stringMoves :: proc(data: []byte) {
	str := string(data)
	for s in strings.split_iterator(&str, "}") {
		fmt.println(s)
	}
}
