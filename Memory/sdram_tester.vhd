--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:35:16 05/31/2017
-- Design Name:   
-- Module Name:   /home/reed/xilinx_projects/r32/sdram_tester.vhd
-- Project Name:  r32
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sdram
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
 
entity sdram_tester is
port
(
    clock50 : in  std_logic;
    leds    : out std_logic_vector (7 downto 0);

    udqm : out std_logic;
    sdram_clk : out std_logic;
    cke : out std_logic;
    ba : out std_logic_vector (1 downto 0);
    sdram_cs : out std_logic;
    ras : out std_logic;
    cas : out std_logic;
    we : out std_logic;
    ldqm : out std_logic;
    ram_addr : out std_logic_vector (12 downto 0);
    ram_data : inout std_logic_vector (15 downto 0)
);
end sdram_tester;

architecture behavior of sdram_tester is 
 
    type row is array (0 to 511) of std_logic_vector (15 downto 0);

    constant testdata : row := (0 => x"d707", 1 => x"e902", 2 => x"be2c", 3 => x"3bc", 4 => x"e691", 5 => x"8539", 6 => x"c0e3", 7 => x"77e0", 8 => x"de0d", 9 => x"f9fa", 10 => x"f63b", 11 => x"f1cb", 12 => x"2853", 13 => x"b813", 14 => x"22da", 15 => x"cb34", 16 => x"adf", 17 => x"bbe", 18 => x"c3c8", 19 => x"ae4c", 20 => x"8f06", 21 => x"2f3e", 22 => x"4f4a", 23 => x"7805", 24 => x"2792", 25 => x"37cc", 26 => x"ecf9", 27 => x"126b", 28 => x"febf", 29 => x"aa60", 30 => x"ca5f", 31 => x"f7fa", 32 => x"c8fd", 33 => x"f89e", 34 => x"cb42", 35 => x"7275", 36 => x"27e6", 37 => x"b38b", 38 => x"1e10", 39 => x"aa9e", 40 => x"89a5", 41 => x"764", 42 => x"eca3", 43 => x"b2ad", 44 => x"3609", 45 => x"9921", 46 => x"14", 47 => x"c92f", 48 => x"a8b6", 49 => x"fdc2", 50 => x"af1f", 51 => x"fe0f", 52 => x"2c4", 53 => x"6f41", 54 => x"9fc1", 55 => x"c1bc", 56 => x"89d9", 57 => x"af05", 58 => x"fd61", 59 => x"fc98", 60 => x"5b3", 61 => x"1a9", 62 => x"979", 63 => x"6bd1", 64 => x"b185", 65 => x"20de", 66 => x"c5cb", 67 => x"1f4", 68 => x"25a6", 69 => x"9724", 70 => x"87aa", 71 => x"4473", 72 => x"267d", 73 => x"68b", 74 => x"2dc8", 75 => x"1a0b", 76 => x"254e", 77 => x"5c35", 78 => x"15c7", 79 => x"4801", 80 => x"a76a", 81 => x"64a7", 82 => x"d993", 83 => x"7c9c", 84 => x"a33c", 85 => x"d830", 86 => x"a492", 87 => x"a6ae", 88 => x"666a", 89 => x"a856", 90 => x"10f8", 91 => x"85d", 92 => x"8ca3", 93 => x"f768", 94 => x"f309", 95 => x"b610", 96 => x"52de", 97 => x"7b1", 98 => x"9246", 99 => x"1fc3", 100 => x"659d", 101 => x"e5e8", 102 => x"6a12", 103 => x"23d3", 104 => x"bff5", 105 => x"863c", 106 => x"66dc", 107 => x"2a61", 108 => x"c1a9", 109 => x"2dcd", 110 => x"77bf", 111 => x"75d2", 112 => x"8f94", 113 => x"2937", 114 => x"2a5d", 115 => x"4966", 116 => x"cc19", 117 => x"a15a", 118 => x"2c2c", 119 => x"fa8c", 120 => x"f62d", 121 => x"531c", 122 => x"5ce3", 123 => x"bf8a", 124 => x"1023", 125 => x"11a1", 126 => x"6ae4", 127 => x"7af", 128 => x"5d6f", 129 => x"23fb", 130 => x"be7a", 131 => x"679f", 132 => x"5031", 133 => x"f9c8", 134 => x"37d5", 135 => x"3cd3", 136 => x"51c", 137 => x"cf79", 138 => x"3e27", 139 => x"287c", 140 => x"e54b", 141 => x"151c", 142 => x"526a", 143 => x"6982", 144 => x"e8dc", 145 => x"48d0", 146 => x"28e7", 147 => x"4ca", 148 => x"5257", 149 => x"4b3c", 150 => x"66e0", 151 => x"e581", 152 => x"cedb", 153 => x"6e7f", 154 => x"f31b", 155 => x"c19a", 156 => x"9831", 157 => x"f4eb", 158 => x"31f1", 159 => x"6f4d", 160 => x"1c90", 161 => x"dabe", 162 => x"558a", 163 => x"6f94", 164 => x"c0b0", 165 => x"a0bd", 166 => x"fac3", 167 => x"c955", 168 => x"cf32", 169 => x"9e62", 170 => x"3836", 171 => x"b05d", 172 => x"f094", 173 => x"520c", 174 => x"bcda", 175 => x"5c76", 176 => x"e8a2", 177 => x"1e82", 178 => x"46a7", 179 => x"5cbb", 180 => x"7676", 181 => x"f5ec", 182 => x"92", 183 => x"60d5", 184 => x"ca80", 185 => x"dc0e", 186 => x"d96b", 187 => x"b534", 188 => x"1807", 189 => x"3c88", 190 => x"8ff4", 191 => x"bb1f", 192 => x"276b", 193 => x"b17", 194 => x"33d1", 195 => x"dccf", 196 => x"1139", 197 => x"5498", 198 => x"6a94", 199 => x"7b04", 200 => x"66ae", 201 => x"6767", 202 => x"1b22", 203 => x"474", 204 => x"c76", 205 => x"c37e", 206 => x"5dd5", 207 => x"d084", 208 => x"35e8", 209 => x"564d", 210 => x"f9c3", 211 => x"cc22", 212 => x"373b", 213 => x"53e7", 214 => x"e741", 215 => x"79a4", 216 => x"25b8", 217 => x"b7db", 218 => x"c3a1", 219 => x"bea0", 220 => x"5071", 221 => x"a0f1", 222 => x"33e4", 223 => x"a58d", 224 => x"fd49", 225 => x"ef9", 226 => x"f5eb", 227 => x"9d27", 228 => x"abc2", 229 => x"7977", 230 => x"c2fc", 231 => x"8106", 232 => x"9c1f", 233 => x"5b22", 234 => x"1df5", 235 => x"83e2", 236 => x"75d2", 237 => x"e6a5", 238 => x"8e3", 239 => x"7037", 240 => x"6579", 241 => x"2aa3", 242 => x"ab60", 243 => x"bd47", 244 => x"f651", 245 => x"80e6", 246 => x"4f67", 247 => x"153d", 248 => x"ac7", 249 => x"20e6", 250 => x"4d53", 251 => x"ee0f", 252 => x"2564", 253 => x"1f37", 254 => x"ef85", 255 => x"5774", 256 => x"61b7", 257 => x"7ec8", 258 => x"7114", 259 => x"d68a", 260 => x"b543", 261 => x"81a5", 262 => x"d5b1", 263 => x"82f4", 264 => x"77b4", 265 => x"208f", 266 => x"75a2", 267 => x"a528", 268 => x"78ac", 269 => x"42fe", 270 => x"9064", 271 => x"ae4c", 272 => x"fad0", 273 => x"765f", 274 => x"c740", 275 => x"2f7c", 276 => x"23ba", 277 => x"7fd1", 278 => x"150a", 279 => x"96e2", 280 => x"2169", 281 => x"696b", 282 => x"6a96", 283 => x"3b7a", 284 => x"9c8b", 285 => x"b8b0", 286 => x"55b0", 287 => x"3dea", 288 => x"9442", 289 => x"710f", 290 => x"9d73", 291 => x"b3d0", 292 => x"771d", 293 => x"628f", 294 => x"bbf", 295 => x"d7d9", 296 => x"23c9", 297 => x"5cad", 298 => x"47c1", 299 => x"dfcb", 300 => x"402", 301 => x"ec3f", 302 => x"103a", 303 => x"2226", 304 => x"473a", 305 => x"7df5", 306 => x"390a", 307 => x"baa", 308 => x"ef59", 309 => x"b5fd", 310 => x"d0f1", 311 => x"2fdd", 312 => x"c79b", 313 => x"da5e", 314 => x"432f", 315 => x"a334", 316 => x"e644", 317 => x"dd07", 318 => x"981a", 319 => x"e190", 320 => x"5058", 321 => x"725f", 322 => x"9c35", 323 => x"6f76", 324 => x"3a96", 325 => x"5879", 326 => x"fa2e", 327 => x"13d0", 328 => x"6af2", 329 => x"6a60", 330 => x"7987", 331 => x"d021", 332 => x"68", 333 => x"89c6", 334 => x"57b6", 335 => x"34ff", 336 => x"1b05", 337 => x"e76f", 338 => x"71ce", 339 => x"9da4", 340 => x"276b", 341 => x"94d0", 342 => x"aabb", 343 => x"f265", 344 => x"dca1", 345 => x"3bcd", 346 => x"8607", 347 => x"5877", 348 => x"7447", 349 => x"e782", 350 => x"6596", 351 => x"aeae", 352 => x"bcaf", 353 => x"9a2d", 354 => x"348f", 355 => x"a7b0", 356 => x"75ec", 357 => x"e290", 358 => x"2fb", 359 => x"f384", 360 => x"9e0f", 361 => x"d456", 362 => x"bb4b", 363 => x"3ee1", 364 => x"5a32", 365 => x"4985", 366 => x"ad86", 367 => x"9f58", 368 => x"118d", 369 => x"9907", 370 => x"7c41", 371 => x"9cd3", 372 => x"b70a", 373 => x"3102", 374 => x"e9a7", 375 => x"be51", 376 => x"bae5", 377 => x"a949", 378 => x"a6e4", 379 => x"b509", 380 => x"86fa", 381 => x"684d", 382 => x"75d8", 383 => x"c81d", 384 => x"2c2", 385 => x"35dd", 386 => x"d80c", 387 => x"e3c1", 388 => x"8188", 389 => x"612f", 390 => x"a173", 391 => x"f7a5", 392 => x"7265", 393 => x"d9bd", 394 => x"f898", 395 => x"3bb4", 396 => x"1543", 397 => x"2458", 398 => x"3fd0", 399 => x"2843", 400 => x"a0b", 401 => x"1481", 402 => x"191c", 403 => x"db1d", 404 => x"26b1", 405 => x"a408", 406 => x"b22f", 407 => x"34c", 408 => x"166d", 409 => x"cba", 410 => x"fac8", 411 => x"f19", 412 => x"290a", 413 => x"a687", 414 => x"2268", 415 => x"93c9", 416 => x"479a", 417 => x"be6b", 418 => x"55cc", 419 => x"f276", 420 => x"ba4a", 421 => x"9dee", 422 => x"a30a", 423 => x"2547", 424 => x"c36f", 425 => x"f498", 426 => x"79e7", 427 => x"9e2f", 428 => x"823a", 429 => x"d4", 430 => x"c1e3", 431 => x"b595", 432 => x"3362", 433 => x"4d2e", 434 => x"8c6", 435 => x"1dec", 436 => x"669d", 437 => x"6ed1", 438 => x"b578", 439 => x"6df6", 440 => x"5013", 441 => x"f757", 442 => x"2079", 443 => x"808a", 444 => x"eefa", 445 => x"1470", 446 => x"9fff", 447 => x"2a4a", 448 => x"558a", 449 => x"c239", 450 => x"7159", 451 => x"2235", 452 => x"31df", 453 => x"162f", 454 => x"50ec", 455 => x"d83d", 456 => x"1d9e", 457 => x"7a3d", 458 => x"e051", 459 => x"ce7b", 460 => x"bfeb", 461 => x"3d2", 462 => x"157e", 463 => x"2411", 464 => x"b3c", 465 => x"6470", 466 => x"8f24", 467 => x"b8a0", 468 => x"e520", 469 => x"5634", 470 => x"653a", 471 => x"e329", 472 => x"893e", 473 => x"82f6", 474 => x"5a01", 475 => x"d22f", 476 => x"4a8e", 477 => x"631c", 478 => x"2e9d", 479 => x"101c", 480 => x"9345", 481 => x"3e0d", 482 => x"1a01", 483 => x"6d3e", 484 => x"d287", 485 => x"efd7", 486 => x"1c9f", 487 => x"a582", 488 => x"1da6", 489 => x"946b", 490 => x"1027", 491 => x"e96a", 492 => x"d393", 493 => x"6fc8", 494 => x"2f7f", 495 => x"d176", 496 => x"103c", 497 => x"ddb4", 498 => x"874a", 499 => x"d0f7", 500 => x"d035", 501 => x"a0c1", 502 => x"cdf8", 503 => x"c75d", 504 => x"92f0", 505 => x"ef35", 506 => x"4414", 507 => x"45cc", 508 => x"81bb", 509 => x"a04e", 510 => x"4560", 511 => x"7971");

    type tester_states is (wrt, rd, idle);

    signal tester : tester_states := wrt;
 
    component sdram
    port(
        clock : in  std_logic;
        read_req : in  std_logic;
        write_req : in  std_logic;
        cs : in  std_logic;
        d_in : in  std_logic_vector (15 downto 0);
        d_out : out  std_logic_vector (15 downto 0);
        addr : in  std_logic_vector (23 downto 0);
        read_ready : out  std_logic;
        write_ready : out  std_logic;
        rd_from_buff : in  std_logic;
        wrt_to_buff : in  std_logic;
        sdram_clk : out  std_logic;
        cke : out  std_logic;
        udqm : out  std_logic;
        ldqm : out  std_logic;
        ba : out  std_logic_vector(1 downto 0);
        sdram_cs : out  std_logic;
        ras : out  std_logic;
        cas : out  std_logic;
        we : out  std_logic;
        ram_addr : out  std_logic_vector (12 downto 0);
        ram_data_in : out  std_logic_vector (15 downto 0);
        ram_data_out : in  std_logic_vector (15 downto 0);
        ram_data_sel : out std_logic
        );
    end component;


    --inputs
    signal read_req : std_logic := '0';
    signal write_req : std_logic := '0';
    signal rd_from_buff : std_logic := '0';
    signal wrt_to_buff : std_logic := '0';
    signal ram_data_out : std_logic_vector (15 downto 0) := (others => '0');

    --outputs
    signal d_out : std_logic_vector (15 downto 0);
    signal read_ready : std_logic;
    signal write_ready : std_logic;
    signal ram_data_in : std_logic_vector (15 downto 0);
    signal ram_data_sel : std_logic;

    signal wrt_timer : integer := 512;
 
begin

    uut: sdram
    port map (
        clock => clock50,
        read_req => read_req,
        write_req => write_req,
        cs => '1',
        d_in => x"abcd",
        d_out => d_out,
        addr => x"000000",
        read_ready => read_ready,
        write_ready => write_ready,
        rd_from_buff => rd_from_buff,
        wrt_to_buff => wrt_to_buff,
        sdram_clk => sdram_clk,
        cke => cke,
        udqm => udqm,
        ldqm => ldqm,
        ba => ba,
        sdram_cs => sdram_cs,
        ras => ras,
        cas => cas,
        we => we,
        ram_addr => ram_addr,
        ram_data_in => ram_data_in,
        ram_data_out => ram_data_out,
        ram_data_sel => ram_data_sel
    );

    testfsm : process (clock50, tester)
    begin
        if rising_edge(clock50) then
            case tester is
                when wrt =>
                    if (wrt_timer > 0) then
                        wrt_timer <= wrt_timer - 1;
                    else
                        tester <= rd;
                    end if;
                when rd => tester <= idle;
                when idle => tester <= idle;
            end case;
        end if;
    end process;

    fsmcomb : process (tester)
    begin
        case tester is
            when wrt =>
                if wrt_timer = 512 then
                    write_req <= '1';
                else
                    write_req <= '0';
                end if;
                wrt_to_buff <= '1';
            when rd =>
                read_req <= '1';
            when idle =>
                read_req <= '0';
                rd_from_buff <= '1';
        end case;
    end process;

    latchdata : process (clock50, read_ready)
    begin
        if rising_edge(clock50) and read_ready = '1' then
            leds <= d_out (7 downto 0);
        end if;
    end process;

    ram_data <= ram_data_in when ram_data_sel = '1' else (others => 'Z');
    ram_data_out <= ram_data;
end;
